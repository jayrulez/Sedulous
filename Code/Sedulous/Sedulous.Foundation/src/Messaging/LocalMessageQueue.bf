using System;
using System.Collections;
using System.Threading;
using Sedulous.Foundation.Collections;
namespace Sedulous.Foundation.Messaging;

using internal Sedulous.Foundation.Messaging;

/// <summary>
/// Represents a message queue which exists entirely within the local process.
/// </summary>
/// <typeparam name="TMessageType">The type of message which is published by the queue.</typeparam>
class LocalMessageQueue<TMessageType> : IMessageQueue<TMessageType> where TMessageType : IEquatable<TMessageType>, IHashable
{
	/// <summary>
	/// Represents a pending message in the message queue.
	/// </summary>
	protected class EnqueuedMessage
	{
		/// <summary>
		/// The message type.
		/// </summary>
		public TMessageType Type
		{
			get;
			internal set;
		}

		/// <summary>
		/// The message data.
		/// </summary>
		public MessageData Data
		{
			get;
			internal set;
		}
	}

	// The queue's message data pools.
	private readonly ExpandingPoolRegistry mMessageDataPools = new ExpandingPoolRegistry() ~ delete _;
	private readonly Monitor mMessageDataPoolsMonitor = new .() ~ delete _;

	// The queue's pending messages.
	private readonly Queue<EnqueuedMessage> mQueue ~ delete _;
	private readonly IPool<EnqueuedMessage> mQueuePool ~ delete _;
	private readonly Monitor mQueueMonitor = new .() ~ delete _;
	private readonly Monitor mQueuePoolMonitor = new .() ~ delete _;

	// The queue's subscriber registry.
	private readonly SubscriberCollection<TMessageType> mSubscribers = new SubscriberCollection<TMessageType>() ~ delete _;
	private readonly Monitor mSubscribersMonitor = new .() ~ delete _;

	/// <summary>
	/// Initializes a new instance of the <see cref="LocalMessageQueue{TMessageType}"/> class with the default capacity.
	/// </summary>
	public this()
		: this(4)
	{
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="LocalMessageQueue{TMessageType}"/> class with the specified initial capacity.
	/// </summary>
	/// <param name="capacity">The initial capacity of the message queue's pools.</param>
	public this(int capacity)
	{
		mQueue = new Queue<EnqueuedMessage>(capacity);
		mQueuePool = new ExpandingPool<EnqueuedMessage>((.)capacity, new () => new EnqueuedMessage(), new (queuePool) => { delete queuePool; });
	}

	/// <summary>
	/// Creates or retrieves an instance of the specified message data type.
	/// The instance may be retrieved from a pool; if so, it will be returned to the pool 
	/// once it has been published.
	/// </summary>
	/// <typeparam name="TMessageData">The type of message data object to create.</typeparam>
	/// <returns>The instance that was created or retrieved.</returns>
	public TMessageData CreateMessageData<TMessageData>() where TMessageData : MessageData, new
	{
		TMessageData data;
		using (mMessageDataPoolsMonitor.Enter())
		{
			data = mMessageDataPools.Get<TMessageData>(1).Retrieve();
		}
		data.Reset();
		return data;
	}

	/// <inheritdoc/>
	public void Subscribe(IMessageSubscriber<TMessageType> receiver, TMessageType type)
	{
		using (mSubscribersMonitor.Enter())
		{
			mSubscribers[type].Add(receiver);
		}
	}

	/// <inheritdoc/>
	public void Subscribe(IMessageSubscriber<TMessageType> receiver, params TMessageType[] types)
	{
		using (mSubscribersMonitor.Enter())
		{
			if (types != null)
			{
				for (var type in types)
				{
					mSubscribers[type].Add(receiver);
				}
			}
		}
	}

	/// <inheritdoc/>
	public void Unsubscribe(IMessageSubscriber<TMessageType> receiver)
	{
		using (mSubscribersMonitor.Enter())
		{
			mSubscribers.RemoveFromAll(receiver);
		}
	}

	/// <inheritdoc/>
	public void Unsubscribe(IMessageSubscriber<TMessageType> receiver, TMessageType type)
	{
		using (mSubscribersMonitor.Enter())
		{
			mSubscribers[type].Remove(receiver);
		}
	}

	/// <inheritdoc/>
	public void Publish(TMessageType type, MessageData data)
	{
		// If the specified data is potentially mergable, scan the queue
		// for an existing message that can be merged with it and perform the merge.
		if (data != null && data.IsMergeable)
		{
			using (mQueueMonitor.Enter())
			{
				for (var enqueuedMessage in mQueue)
				{
					if (enqueuedMessage.Type.Equals(type))
						continue;

					var merged = data.EvaluateMerge(enqueuedMessage.Data);
					if (merged != null)
					{
						if (!enqueuedMessage.Data.GetType().IsAssignableFrom(merged.GetType()))
							Runtime.FatalError("MessageMergeTypeConflict");

						enqueuedMessage.Data = merged;
						return;
					}
				}
			}
		}

		// If the message could not be merged, add it to the message queue.
		using (mQueueMonitor.Enter())
		{
			mQueue.Add(CreateEnqueuedMessage(type, data));
		}
	}

	/// <inheritdoc/>
	public void PublishImmediate(TMessageType type, MessageData data)
	{
		using (mSubscribersMonitor.Enter())
		{
			mSubscribers.ReceiveMessage(type, data);
		}
	}

	/// <inheritdoc/>
	public void Process()
	{
		while (true)
		{
			// Retrieve the next message from the queue.
			EnqueuedMessage evt;
			using (mQueueMonitor.Enter())
			{
				if (mQueue.Count == 0)
				{
					break;
				}
				evt = mQueue.PopFront();
			}
			

			defer
			{
				if (evt.Data != null)
				{
					using (mMessageDataPoolsMonitor.Enter())
					{
						var pool = mMessageDataPools.Get(evt.Data.GetType());
						if (pool == null)
						{
							Runtime.FatalError("Message Pool Not Found");
						}
						pool.Release(evt.Data);
					}
				}
				using (mQueueMonitor.Enter())
				{
					mQueuePool.Release(evt);
				}
			}

			// Broadcast the message to all subscribers.
			{
				using (mSubscribersMonitor.Enter())
				{
					mSubscribers.ReceiveMessage(evt.Type, evt.Data);
				}
			}

		}
	}

	/// <summary>
	/// Creates an enqueued message.
	/// </summary>
	/// <param name="type">The message type.</param>
	/// <param name="data">The message data.</param>
	/// <returns>The enqueued message.</returns>
	private EnqueuedMessage CreateEnqueuedMessage(TMessageType type, MessageData data)
	{
		var evt = mQueuePool.Retrieve();
		evt.Type = type;
		evt.Data = data;
		return evt;
	}
}