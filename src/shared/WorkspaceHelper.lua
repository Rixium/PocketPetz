local WorkspaceHelper = {};

function WorkspaceHelper.GetDescendantByName(object, name)
    local descendants = object:GetDescendants();

    for index, value in pairs(descendants) do
        if value.Name == name then
            return value;
        end
    end

    return nil;
end

return WorkspaceHelper;