local function MakeShimmer(name, winter_anim)
    local assets =
    {
        Asset("ANIM", "anim/" .. name .. ".zip"),
    }

    if winter_anim then
        table.insert(assets, Asset("ANIM", "anim/ia_wave_hurricane.zip"))
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        --[[Non-networked entity]]
        inst:AddTag("CLASSIFIED")

        if winter_anim then
            if TheWorld.state.iswinter then
                inst.Transform:SetTwoFaced()
                inst.AnimState:SetBuild("ia_wave_hurricane")
                inst.AnimState:SetBank("ia_wave_hurricane")
                inst.AnimState:PlayAnimation("idle_small", false)
            else
                inst.AnimState:SetBuild(name)
                inst.AnimState:SetBank(winter_anim)
                inst.AnimState:PlayAnimation("idle", false)
            end
        else
            inst.AnimState:SetBuild(name)
            inst.AnimState:SetBank(name)
            inst.AnimState:PlayAnimation("idle", false)
        end

        -- inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.WAVE_TINT_AMOUNT)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_WAVES)

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        inst:AddTag("NOBLOCK")
        inst:AddTag("ignorewalkableplatforms")

        if TheNet:GetIsClient() then
            inst.entity:AddClientSleepable()
        end

        inst.OnEntitySleep = inst.Remove
        inst:ListenForEvent("animover", inst.Remove)

        inst.persists = false

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeShimmer("ia_wave_shimmer", "ia_shimmer"),
    MakeShimmer("ia_wave_shimmer_med", "ia_shimmer"),
    MakeShimmer("ia_wave_shimmer_deep", "ia_shimmer_deep"),
    MakeShimmer("ia_wave_shimmer_flood")
