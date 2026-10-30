# Greedy Algorithm Pseudocode
#START
#    INPUT refund_amount
#    SET denominations = [4, 3, 1]
#    SET count = 0
#    FOR each denomination in denominations DO
#        WHILE refund_amount >= denomination DO
#            SUBTRACT denomination from refund_amount
#            INCREMENT count
#        END WHILE
#    END FOR
#    PRINT minimum number of coins
#END
# Python Code

denominations = [4, 3, 1]

refund_amount = int(input("Enter Refund Amount: "))

count = 0
used_coins = []

for coin in denominations:
    while refund_amount >= coin:
        refund_amount -= coin
        count += 1
        used_coins.append(coin)

print("\nGreedy Approach")
print("Coins Used:", used_coins)
print("Minimum Coins:", count)
