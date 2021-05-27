local command = {}

command.name = "Eval"
command.info = "-"
command.desc = "-"
command.trigger = {"eval"}
command.hidden = true


command.onCommand = function(m)
  if m.author ~= Misc.client.owner then
    -- Log if someone attempts to use eval
    p(Misc.getName(m.author.id, m.guild).." ["..m.author.id.."] is attempting to use eval")
  else
    Misc.exec(m, table.join(Misc.getParameters(m), " "))
  end
end

return command
