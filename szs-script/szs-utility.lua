SET_SZS=0x900

Symphogear = {}

function Symphogear.EffectProcedure(c,id,default,list)
    --spsummon
    local eff=Effect.CreateEffect(c)
	eff:SetType(EFFECT_TYPE_FIELD)
	eff:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	eff:SetCode(EFFECT_SPSUMMON_PROC)
	eff:SetRange(LOCATION_HAND)
	eff:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	eff:SetCondition(Symphogear.EffectCondition)
	eff:SetOperation(Symphogear.EffectOperation)
	c:RegisterEffect(eff)
	--addition effect
    if default==nil then
		local exx=Effect.CreateEffect(c)
		exx:SetDescription(aux.Stringid(id,0))
		exx:SetCategory(list.category)
		exx:SetType(EFFECT_TYPE_IGNITION)
		exx:SetRange(LOCATION_MZONE)
		exx:SetCountLimit(1,id)
		exx:SetTarget(list.target)
		exx:SetOperation(list.operation)
		c:RegisterEffect(exx)
	elseif default==true then
		local exx=Effect.CreateEffect(c)
		exx:SetDescription(aux.Stringid(id,0))
		if list.category~=nil then exx:SetCategory(list.category) end
		if list.code~=nil then exx:SetCode(list.code) end
		if list.type~=nil then exx:SetType(list.type) end
		if list.range~=nil then exx:SetRange(list.range) end
		if list.property~=nil then exx:SetProperty(list.property) end
		exx:SetCountLimit(1,id)
		if list.condition~=nil then exx:SetCondition(list.condition) end
		if list.cost~=nil then exx:SetCost(list.cost) end
		if list.target~=nil then exx:SetTarget(list.target) end
		if list.operation~=nil then exx:SetOperation(list.operation) end
		c:RegisterEffect(exx)
	else
		Debug.Message("Symphogear.EffectProcedure: default value is not true or nil")
	end
end
function Symphogear.EffectConditionFilter(c)
    return c:IsFacedown() or not c:IsSetCard(SET_SZS)
end
function Symphogear.EffectCondition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and not Duel.IsExistingMatchingCard(Symphogear.EffectConditionFilter,tp,LOCATION_MZONE,0,1,nil)
end
function Symphogear.EffectOperation(e,tp,eg,ep,ev,re,r,rp,c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsSetCard(SET_SZS) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.addTempLizardCheck(c,tp,function(e,c) return not c:IsSetCard(SET_SZS) end)
end
function Symphogear.XyzSummonProcedure(c,id)
    c:EnableReviveLimit()
	--xyz procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SZS),4,2)
    --destroy replace
    local eff=Effect.CreateEffect(c)
	eff:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	eff:SetCode(EFFECT_DESTROY_REPLACE)
    eff:SetCountLimit(1,{id,1})
	eff:SetRange(LOCATION_MZONE)
	eff:SetTarget(Symphogear.XyzSummonDestroyReplace)
	c:RegisterEffect(eff)
end
function Symphogear.XyzSummonDestroyReplace(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
        and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end
function Symphogear.IncreaseATK(c,list)
    local eff=Effect.CreateEffect(c)
	eff:SetType(EFFECT_TYPE_SINGLE)
	eff:SetCode(EFFECT_UPDATE_ATTACK)
	eff:SetValue(list.value)
	eff:SetReset(list.reset)
	c:RegisterEffect(eff)
end