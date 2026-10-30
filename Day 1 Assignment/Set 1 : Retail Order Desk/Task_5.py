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
# Dynamic Programming Pseudocode
#START
#    INPUT refund_amount
#    SET denominations = [1, 3, 4]
#    CREATE dp array of size refund_amount + 1
#    INITIALIZE all values to infinity
#    SET dp[0] = 0
#    FOR amount = 1 TO refund_amount DO
#        FOR each coin in denominations DO
#            IF amount >= coin THEN
#                dp[amount] = MIN(dp[amount],
#                                 dp[amount - coin] + 1)
#            END IF
#        END FOR
#    END FOR
#    PRINT dp[refund_amount]
#END
# Python Code

denominations = [1, 3, 4]

refund_amount = int(input("Enter Refund Amount: "))

dp = [float("inf")] * (refund_amount + 1)
dp[0] = 0

for amount in range(1, refund_amount + 1):
    for coin in denominations:
        if amount >= coin:
            dp[amount] = min(
                dp[amount],
                dp[amount - coin] + 1
            )

print("\nDynamic Programming Approach")
print("Minimum Coins:", dp[refund_amount])

# Reconstruct the coins used
amount = refund_amount
used_coins = []

while amount > 0:
    for coin in denominations:
        if amount >= coin and dp[amount] == dp[amount - coin] + 1:
            used_coins.append(coin)
            amount -= coin
            break

print("Coins Used:", used_coins)
