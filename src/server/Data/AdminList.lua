local AdminList = { };
local initialized = false;

AdminList.Admins = {};

function AdminList.SetAdmins(admins)
    for index, value in pairs(admins) do
        table.insert(AdminList.Admins, value);
	end 

    initialized = true;
end

function AdminList.Initialized() 
    return initialized;
end

function AdminList.Contains(player)
    local admins = AdminList.Admins;
    for index, adminName in ipairs(admins) do
        if player.Name:lower() == adminName:lower() then 
            return true;
        end
    end

    return false;
end


return AdminList;