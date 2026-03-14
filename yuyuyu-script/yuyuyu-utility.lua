SETCARD_YUYUYU=0x902
YUYUYU_TOKEN=900132101

YuYuYu = {}

local function getMatLoc(mat_hand)
	local loc=LOCATION_MZONE
	if mat_hand then loc=loc+LOCATION_HAND end
	return loc
end

function YuYuYu.RitualMonsterCheckFilter(c,lv,e,tp)
	if not c then return false end
	return c:IsMonster()
		and c:HasLevel()
		and c:IsLevel(lv)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
		and (c:IsLocation(LOCATION_HAND+LOCATION_DECK) or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,nil,nil,c)>0))
end

function YuYuYu.RitualMaterialCheckFilter(c)
	if not c then return false end
	return c:HasLevel() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end

function YuYuYu.RitualCheck(e,tp,lv,loc,mat_hand)
	if not (e and tp and lv and loc) then return false end
	local mat_loc=getMatLoc(mat_hand)
	local rg=Duel.GetMatchingGroup(YuYuYu.RitualMonsterCheckFilter,tp,loc,0,nil,lv,e,tp)
	if #rg==0 then return false end
	local ex=rg:GetFirst()
	local cg=Duel.GetMatchingGroup(YuYuYu.RitualMaterialCheckFilter,tp,mat_loc,0,ex)
	return cg:CheckWithSumEqual(Card.GetLevel,lv,1,99)
end

function YuYuYu.RitualOperation(e,tp,lv,loc,mat_hand)
	if not (e and tp and lv and loc) then return end
	local mat_loc=getMatLoc(mat_hand)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local rc=Duel.SelectMatchingCard(tp,YuYuYu.RitualMonsterCheckFilter,tp,loc,0,1,1,nil,lv,e,tp):GetFirst()
	if not rc then return end
	local cg=Duel.GetMatchingGroup(YuYuYu.RitualMaterialCheckFilter,tp,mat_loc,0,rc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local mg=cg:SelectWithSumEqual(tp,Card.GetLevel,lv,1,99)
	if not mg or #mg==0 then return end
	rc:SetMaterial(mg)
	Duel.Release(mg,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
	Duel.BreakEffect()
	Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
	rc:CompleteProcedure()
end

function YuYuYu.DestroyPendulumEffect(c,string,tables)
	local eff=Effect.CreateEffect(c)
	eff:SetDescription(string)
	eff:SetCategory(CATEGORY_DESTROY+(tables.category or 0))
	eff:SetType(EFFECT_TYPE_IGNITION)
	eff:SetRange(LOCATION_PZONE)
	eff:SetCountLimit(1,tables.hopt)
	eff:SetTarget(YuYuYu.DestroyPendulumEffectTarget(tables))
	eff:SetOperation(YuYuYu.DestroyPendulumEffectOperation(tables))
	return eff
end

function YuYuYu.DestroyPendulumEffectTarget(tables)
	tables=tables or {}
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then
			local handler_ok=e:GetHandler() and e:GetHandler():IsDestructable()
			local target_ok=type(tables.target)=="function" and tables.target(e,tp,eg,ep,ev,re,r,rp,0)
			return handler_ok and target_ok
		end
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
		if type(tables.setoperationinfo)=="function" then
			tables.setoperationinfo(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end

function YuYuYu.DestroyPendulumEffectOperation(tables)
	tables=tables or {}
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c and c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
			if type(tables.effect)=="function" then
				tables.effect(e,tp)
			end
		end
	end
end

function YuYuYu.DestroyEffect(c,string,tables)
	tables=tables or {}
	local eff=Effect.CreateEffect(c)
	eff:SetDescription(string)
	if tables.category~=nil then eff:SetCategory(tables.category) end
	if tables.force==true then
		eff:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	else
		eff:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	end
	eff:SetCode(EVENT_DESTROYED)
	local hopt=tables.hopt or 0
	eff:SetCountLimit(1,{hopt,2})
	eff:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	eff:SetCondition(YuYuYu.DestroyEffectCondition)
	if type(tables.target)=="function" then eff:SetTarget(tables.target) end
	if type(tables.operation)=="function" then eff:SetOperation(tables.operation) end
	return eff
end

function YuYuYu.DestroyEffectCondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c then return false end
	return (c:IsReason(REASON_BATTLE) or (rp~=tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
end