C_Timer = { };

function C_Timer.After(duration, callback)
    WCollections.AceAddon:ScheduleTimer(callback, duration);
end
