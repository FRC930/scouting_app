import json
import qrcode
import requests

eventCode = input("Enter the event code: ")

token = open("scripts/token", "r").read()

print("Attempting to get teams at event", eventCode, "using token", token)

apiRequest = requests.get("https://frc-api.firstinspires.org/v3.0/2022/teams?eventCode=" +
                          eventCode, headers={"Authorization": "Basic " + token, "If-Modified-Since": ";"})

requestJson = json.loads(apiRequest.text)["teams"]

teamNames = []
teamNumbers = []

for team in requestJson:
    teamNames.append(team["nameShort"])
    teamNumbers.append("Team " + str(team["teamNumber"]))

teamData = "{\n\"Team Names\": " + json.dumps(
    teamNames, indent=4) + ",\n \"Team Numbers\": "+json.dumps(teamNumbers, indent=4)+"\n}"

teamsList = open("scripts/teams_list.json", "w")

print(teamData, file=teamsList)

teamsList.close()

qrcode.make(teamData).save("scripts/teams_list.png")
