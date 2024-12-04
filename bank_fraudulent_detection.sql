use bank_fraud_detection;
SELECT * FROM transactions;

-- identifying potential money laundering chains where money is transffered from one account to another account accross multiple steps and flagged all the transaction fraud--
WITH RECURSIVE money_fraud_chain as (
SELECT nameOrig as initial_account,
nameDest as destination_account,
step,
amount,
newbalanceorig
FROM 
transactions
WHERE isFraud = 1 and type = 'TRANSFER'

UNION ALL 

SELECT mfc.initial_account,
t.nameDest,t.step,t.amount ,t.newbalanceorig
FROM money_fraud_chain mfc
JOIN transactions t
ON mfc.destination_account = t.nameorig and mfc.step < t.step 
where t.isfraud = 1 and t.type = 'TRANSFER')

SELECT * FROM money_fraud_chain;

-- figering out the rolling sum of fraudulent transaction for each account over the last five steps--
with rolling_isFraud as ( SELECT nameorig,step, 
SUM(isfraud) OVER (PARTITION BY nameOrig order by STEP ROWS BETWEEN 4 PRECEDING and CURRENT ROW ) as fraud_rolling_transaction
FROM transactions)

SELECT * FROM rolling_isFraud 
WHERE fraud_rolling_transaction > 0 ;


-- retriving accounts name with suspecious activity,including large amount tranfer more than 500000 amount,consecutive transfer without balace change and flagged transactions --
-- Using multiple CTE and joinning tables through multiple join --
WITH large_amount as (
SELECT nameOrig,step,amount
FROM transactions WHERE type='TRANSFER' AND amount>500000
),
 without_balance_change as (
SELECT nameOrig,step,oldbalanceOrg,newbalanceDest
FROM transactions WHERE oldbalanceOrg = newbalanceorig
),
 is_FlaggedFraud as (
SELECT nameOrig,step
FROM transactions WHERE isFlaggedFraud = 1
)
SELECT  la.nameOrig
FROM large_amount la
JOIN
without_balance_change wbc
ON la.nameOrig=wbc.nameOrig AND la.step=wbc.step
JOIN
is_FlaggedFraud iff
ON la.nameOrig=iff.nameOrig AND la.step=iff.step;

-- 4. Write me a query that checks if the computed new_updated_Balance is the same as the actual newbalanceDest in the table. If they are equal, it returns those rows.--
WITH equality_check AS (
SELECT nameOrig,oldbalanceDest,amount,newbalanceDest,(oldbalanceDest+amount) AS new_updated_Balance
FROM transactions
 )
 
 SELECT *
 FROM equality_check 
 WHERE newbalanceDest = new_updated_Balance;
 
 
 -- Checking if the  oldbalanceDest and newbalanceDest is zero , it returns those rows--
SELECT *
FROM transactions
WHERE oldbalanceDest= newbalanceDest;
-- Or--
SELECT *
FROM transactions 
WHERE oldbalanceDest=0.00 AND newbalanceDest=0.00;

 

















