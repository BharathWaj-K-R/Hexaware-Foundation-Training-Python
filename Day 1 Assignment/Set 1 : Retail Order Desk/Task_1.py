# Linear Search Pseudocode
#START
#    LOAD orders.csv
#    INPUT targetOrderId
#     FOR each order in orders DO
#        IF order.orderId == targetOrderId THEN
#            PRINT "Order Found"
#            PRINT order details
#            STOP
#        END IF
#    END FOR
#    PRINT "Order Not Found"
#END

# Python Code
import csv

orders = []

with open("orders.csv","r",newline = "") as file:
    reader = csv.DictReader(file)
    for row in reader:
        orders.append(row)
        
def linear_search(orders,target_id):
    for order in orders :
        if order["orderId"] == target_id:
            return order
    return None

target_id = input("Enter Order ID: ").strip()
result = linear_search(orders,target_id)

if result is not None:
    print("\nOrder Found!")
    print("Order ID:", result["orderId"])
    print("Customer ID:", result["customerId"])
    print("Amount:", result["amount"])
    print("Created At:", result["createdAt"])
else:
    print("\nOrder Not Found")
#Binary Search Pesudocode
#START
#    LOAD orders.csv
#    SORT orders by orderId in ascending order
#    INPUT targetOrderId
#    SET low = 0
#    SET high = length(orders) - 1
#    WHILE low <= high DO
#        SET mid = (low + high) // 2
#        IF orders[mid].orderId == targetOrderId THEN
#            PRINT "Order Found"
#            PRINT order details
#            STOP
#        ELSE IF orders[mid].orderId < targetOrderId THEN
#            SET low = mid + 1
#        ELSE
#            SET high = mid - 1
#        END IF
#    END WHILE
#    PRINT "Order Not Found"
#END
# Python 
import csv

orders = []
with open("orders.csv", "r", newline="") as file:
    reader = csv.DictReader(file)
    for row in reader:
        orders.append(row)

orders.sort(key=lambda order: order["orderId"])

def binary_search(orders, target_id):
    low = 0
    high = len(orders) - 1
    while low <= high:
        mid = (low + high) // 2
        if orders[mid]["orderId"] == target_id:
            return orders[mid]
        elif orders[mid]["orderId"] < target_id:
            low = mid + 1
        else:
            high = mid - 1
    return None

target_id = input("Enter Order ID: ").strip()
result = binary_search(orders, target_id)

if result is not None:
    print("\nOrder Found!")
    print("Order ID:", result["orderId"])
    print("Customer ID:", result["customerId"])
    print("Amount:", result["amount"])
    print("Created At:", result["createdAt"])
else:
    print("\nOrder Not Found")
