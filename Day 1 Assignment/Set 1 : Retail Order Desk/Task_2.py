# Bubble Sort Pseudocode
#START
#    LOAD orders.csv
#    SET n = length(orders)
#    FOR i = 0 TO n - 1 DO
#        FOR j = 0 TO n - i - 2 DO
#            IF orders[j].amount < orders[j + 1].amount THEN
#                SWAP orders[j] AND orders[j + 1]
#            END IF
#        END FOR
#    END FOR
#    PRINT sorted orders
#END

# Python Code

import csv

orders = []

with open("orders.csv", "r", newline="") as file:
    reader = csv.DictReader(file)
    for row in reader:
        row["amount"] = float(row["amount"])
        orders.append(row)

def bubble_sort(orders):
    n = len(orders)
    for i in range(n):
        for j in range(0, n - i - 1):
            if orders[j]["amount"] < orders[j + 1]["amount"]:
                orders[j], orders[j + 1] = orders[j + 1], orders[j]
    return orders

sorted_orders = bubble_sort(orders)

print("Top 10 Orders by Amount:")
for order in sorted_orders[:10]:
    print(order)

# Merge Sort Pseudocode
#START
#    LOAD orders.csv
#    CALL merge_sort(orders)
#
#    FUNCTION merge_sort(orders)
#        IF length(orders) <= 1 THEN
#            RETURN orders
#        END IF
#
#        SET mid = length(orders) // 2
#        DIVIDE orders into left and right
#
#        SET left = merge_sort(left)
#        SET right = merge_sort(right)
#
#        MERGE left and right in descending order
#        RETURN merged list
#    END FUNCTION
#
#    PRINT sorted orders
#END

# Python Code

import csv

orders = []

with open("orders.csv", "r", newline="") as file:
    reader = csv.DictReader(file)
    for row in reader:
        row["amount"] = float(row["amount"])
        orders.append(row)

def merge_sort(orders):
    if len(orders) <= 1:
        return orders

    mid = len(orders) // 2

    left = merge_sort(orders[:mid])
    right = merge_sort(orders[mid:])

    return merge(left, right)

def merge(left, right):
    result = []
    i = 0
    j = 0

    while i < len(left) and j < len(right):
        if left[i]["amount"] >= right[j]["amount"]:
            result.append(left[i])
            i += 1
        else:
            result.append(right[j])
            j += 1

    result.extend(left[i:])
    result.extend(right[j:])

    return result

sorted_orders = merge_sort(orders)

print("Top 10 Orders by Amount:")
for order in sorted_orders[:10]:
    print(order)

