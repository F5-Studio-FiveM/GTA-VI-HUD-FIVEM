exports('Notify', function(target, data, ntype, duration)
    if type(data) ~= 'table' then data = { message = data, type = ntype, duration = duration } end
    TriggerClientEvent('gta6_notify:client:notify', target, data)
end)
