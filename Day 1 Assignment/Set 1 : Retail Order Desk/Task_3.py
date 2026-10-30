# Duplicate Order Detection Pseudocode
#START
#    LOAD orders.csv
#    CREATE an empty hash_map
#    FOR each order in orders DO
#        EXTRACT customerId, amount and createdAt
#        EXTRACT date and time up to the minute
#        CREATE key = (customerId, amount, minute)
#        IF key exists in hash_map THEN
#            PRINT "Duplicate Order Found"
#            PRINT previous order and current order
#        ELSE
#            STORE order in hash_map using key
#        END IF
#    END FOR
#END
# Python Code

import csv

orders = []

with open("orders.csv", "r", newline="") as file:
    reader = csv.DictReader(file)
    for row in reader:
        orders.append(row)
hash_map = {}
duplicates = []
for order in orders:
    customer_id = order["customerId"]
    amount = order["amount"]
    minute = order["createdAt"][:16]

    key = (customer_id, amount, minute)

    if key in hash_map:
        duplicates.append((hash_map[key], order))
    else:
        hash_map[key] = order

if duplicates:
    print("Duplicate Orders Found!")
    print("Total Duplicate Pairs:", len(duplicates))

    for first, second in duplicates:
        print("\nFirst Order:", first["orderId"])
        print("Second Order:", second["orderId"])
        print("Customer ID:", first["customerId"])
        print("Amount:", first["amount"])
        print("Time:", first["createdAt"][:16])

else:
    print("No Duplicate Orders Found")
