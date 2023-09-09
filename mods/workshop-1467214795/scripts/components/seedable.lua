local Seedable = Class(function(self, inst)
    self.inst = inst
    self.growtime = 120
    self.product = nil
    self.minlevel = 1
end)

return Seedable