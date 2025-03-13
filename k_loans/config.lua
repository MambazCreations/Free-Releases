Config = {}

-- Interest rate for loans
Config.InterestRate = 0.1 -- 10% interest

-- Maximum loan amount allowed
Config.MaxLoanAmount = 100000

-- Loan Shark NPC model
Config.PedModel = 's_m_y_dealer_01'

-- Loan Shark locations
Config.Locations = {
    {x = 119.30, y = -1947.20, z = 20.00, h = 180.0},
    {x = 372.34, y = -1034.14, z = 29.34, h = 270.0}
}

-- Whether to display a blip on the map
Config.ShowBlip = true
Config.BlipSprite = 500
Config.BlipColor = 1
Config.BlipScale = 0.75

-- Operating hours for the Loan Shark (24-hour format)
Config.OpenHours = {
    start = 20, -- 8:00 PM
    finish = 6   -- 6:00 AM
}

-- ✅ NPC Settings for Missed Loan Repayment
Config.NPCWeapons = {"WEAPON_PISTOL", "WEAPON_SMG"}
Config.NPCDifficulty = {
    health = 200,   -- NPC health
    accuracy = 75,  -- Shooting accuracy (0-100)
    armor = 50      -- NPC armor
}
Config.NPCCount = 3 -- Number of NPCs to spawn

-- ✅ Time to repay loan (in minutes)
Config.RepaymentTime = 1
