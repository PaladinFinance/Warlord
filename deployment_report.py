import json

f = open("./broadcast/Deploy.s.sol/1/run-latest.json")

txs = json.load(f)["transactions"]

report = {}

for tx in txs:
  if tx["transactionType"] == "CREATE":
    report[tx["contractName"]] = tx["contractAddress"]

print(report)
f.close()

w = open("./deployment_report.json", 'w')

json_report = json.dumps(report, indent=2)
w.write(json_report)

w.close()
