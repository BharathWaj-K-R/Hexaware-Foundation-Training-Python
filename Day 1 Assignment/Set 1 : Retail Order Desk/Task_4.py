# Stack and Queue Pseudocode
#START
#    CREATE a Stack
#    CREATE an empty list to store elements
#
#    DEFINE PUSH operation
#        ADD element to the top of Stack
#
#    DEFINE POP operation
#        IF Stack is not empty THEN
#            REMOVE and RETURN top element
#        ELSE
#            PRINT "Stack is Empty"
#        END IF
#
#    CREATE a Queue
#    CREATE an empty list to store elements
#
#    DEFINE ENQUEUE operation
#        ADD element to the rear of Queue
#
#    DEFINE DEQUEUE operation
#        IF Queue is not empty THEN
#            REMOVE and RETURN front element
#        ELSE
#            PRINT "Queue is Empty"
#        END IF
#
#    PUSH order edits into Stack
#    POP last edit to perform undo
#
#    ENQUEUE orders into Queue
#    DEQUEUE orders for dispatch
#
#    REPLACE custom Stack with built-in List
#    REPLACE custom Queue with built-in Deque
#END
# Python Code

class Stack:
    def __init__(self):
        self.items = []

    def push(self, item):
        self.items.append(item)

    def pop(self):
        if not self.is_empty():
            return self.items.pop()
        return None

    def is_empty(self):
        return len(self.items) == 0

class Queue:
    def __init__(self):
        self.items = []

    def enqueue(self, item):
        self.items.append(item)

    def dequeue(self):
        if not self.is_empty():
            return self.items.pop(0)
        return None

    def is_empty(self):
        return len(self.items) == 0


stack = Stack()

stack.push("ORD101: Amount changed to 500")
stack.push("ORD102: Amount changed to 700")
stack.push("ORD103: Amount changed to 900")

print("Undo Operation:")
print("Last Edit:", stack.pop())

print("\nRemaining Stack:", stack.items)

queue = Queue()

queue.enqueue("ORD101")
queue.enqueue("ORD102")
queue.enqueue("ORD103")

print("\nOrder Dispatch:")

while not queue.is_empty():
    print("Dispatching:", queue.dequeue())
