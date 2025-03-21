Loan Sharking Script for FiveM
📌 Description
This is a Loan Sharking script for FiveM that allows players to take loans from a Loan Shark NPC, repay loans with interest, and face consequences if loans are not repaid on time. The script includes configurable settings for interest rates, loan limits, repayment times, and NPC behavior for missed payments.

This script uses:

ox_lib – for UI and notifications
ox_target – for interaction with the Loan Shark NPC
qb-core – for handling player data and money
oxmysql – for managing loan data in the database

🛠️ Features
✅ Take loans with configurable limits and interest rates
✅ Repay loans with interest before the deadline
✅ NPC attackers hunt down the player if the loan isn’t repaid on time
✅ Configurable NPC behavior, including health, accuracy, and weapons
✅ Loan Shark NPC spawns at a random location every server restart
✅ Operating hours for the Loan Shark can be customized
✅ Fully synced with database – loan data persists across restarts
✅ Blip option to show the Loan Shark location on the map

⚙️ Installation
Download the script and place it in the resources folder of your FiveM server.
Add ensure loanshark to your server.cfg

Import SQL into your database:

CREATE TABLE IF NOT EXISTS `loans` (
  `citizenid` VARCHAR(50) NOT NULL,
  `amount` INT NOT NULL,
  `deadline` BIGINT NOT NULL,
  PRIMARY KEY (`citizenid`)
);

Dependencies – Ensure these resources are installed and running:
ox_lib
ox_target
qb-core
oxmysql

📝 Configuration
Open config.lua to adjust the script to your needs:

Interest Rate & Loan Limits
InterestRate – Interest rate applied to loans
MaxLoanAmount – Maximum amount a player can borrow

Config.InterestRate = 0.1 -- 10% interest
Config.MaxLoanAmount = 100000
Loan Shark NPC Settings
PedModel – NPC model for the Loan Shark
Locations – Random spawn locations for the Loan Shark NPC
ShowBlip – Whether to display the NPC location on the map

Config.PedModel = 's_m_y_dealer_01'
Config.Locations = {
    {x = 119.30, y = -1947.20, z = 20.00, h = 180.0},
    {x = 372.34, y = -1034.14, z = 29.34, h = 270.0}
}
Config.ShowBlip = true
Operating Hours
Start/Finish – Define when the Loan Shark is available

Config.OpenHours = {
    start = 20, -- 8:00 PM
    finish = 6   -- 6:00 AM
}
NPC Behavior for Missed Payments
NPCWeapons – Weapons NPCs will use
NPCDifficulty – Adjust health, accuracy, and armor
NPCCount – Number of NPCs that will hunt the player

Config.NPCWeapons = {"WEAPON_PISTOL", "WEAPON_SMG"}
Config.NPCDifficulty = {
    health = 200,
    accuracy = 75,
    armor = 50
}
Config.NPCCount = 3
Repayment Time
RepaymentTime – Time to repay loan (in minutes)

Config.RepaymentTime = 1
🚀 How to Use
🏦 Taking a Loan
Approach the Loan Shark NPC.
Use the interaction key to open the loan menu.
Choose the loan amount (up to the configured max).
Loan amount will be deposited into your cash.
💰 Repaying a Loan
Approach the Loan Shark NPC.
Use the interaction key to open the repayment menu.
If you have enough cash, you can repay the loan + interest.
🚨 Consequences for Missing Payment
If the repayment deadline passes:
NPCs will spawn and attack the player.
NPCs will have configurable health, accuracy, and weapons.
NPCs will stop once the player dies or the loan is repaid.

🔥 Commands
Command	Description
/startloanshark	Force the Loan Shark to spawn
/stoploanshark	Remove the Loan Shark NPC
/resetloan	Reset all active loans (Admin only)

🚨 Troubleshooting
✅ NPC Not Spawning
Ensure the PedModel is valid.
Check that the location is accessible.
Ensure operating hours are set correctly.
✅ Loan Repayment Not Working
Ensure the player has enough cash.
Check for errors in the server console.
✅ NPCs Not Attacking
Ensure weapons are valid.
Check NPC health and accuracy settings.
📢 Future Updates
✅ More NPC variation
✅ Configurable repayment methods (bank vs. cash)
✅ Additional consequences for missed payments
💖 Credits
Script Author – YourName
Framework – QBCore
Dependencies – ox_lib, ox_target, oxmysql
