SETCARD_YUYUYU=0x902
YUYUYU_TOKEN=900132101

YuYuYu = {}

function YuYuYu.RitualMonsterCheckFilter(c,lv,e,tp)
    return c:IsMonster() and c:HasLevel() and c:IsLevel(lv) and c:HasLevel(lv)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
        and (c:IsLocation(LOCATION_HAND+LOCATION_DECK) or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,nil,nil,c)>0))
end
function YuYuYu.RitualMaterialCheckFilter(c)
    return c:HasLevel() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function YuYuYu.RitualCheck(e,tp,lv,loc,mat_hand)
    local mat_loc=LOCATION_MZONE
    if mat_hand==true then
        mat_loc=mat_loc+LOCATION_HAND
    end
    local rg=Duel.GetMatchingGroup(YuYuYu.RitualMonsterCheckFilter,tp,loc,0,nil,lv,e,tp)
    if #rg==0 then return false end
    local cg=Duel.GetMatchingGroup(YuYuYu.RitualMaterialCheckFilter,tp,mat_loc,0,rg:GetFirst())
    if cg:CheckWithSumEqual(Card.GetLevel,lv,1,99) then
        return true
    end
    return false
end

function YuYuYu.RitualOperation(e,tp,lv,loc,mat_hand)
    local mat_loc=LOCATION_MZONE
    if mat_hand==true then
        mat_loc=mat_loc+LOCATION_HAND
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local rc=Duel.SelectMatchingCard(tp,YuYuYu.RitualMonsterCheckFilter,tp,loc,0,1,1,nil,lv,e,tp):GetFirst()
    if not rc then return end
    local cg=Duel.GetMatchingGroup(YuYuYu.RitualMaterialCheckFilter,tp,mat_loc,0,rc)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local mg=cg:SelectWithSumEqual(tp,Card.GetLevel,lv,1,99)
    if #mg==0 then return end
    rc:SetMaterial(mg)
    Duel.Release(mg,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    Duel.BreakEffect()
    Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
    rc:CompleteProcedure()
end

function YuYuYu.DestroyPendulumEffect(c,string,tables)
    local eff=Effect.CreateEffect(c)
	eff:SetDescription(string)
	eff:SetCategory(CATEGORY_DESTROY+tables.category)
	eff:SetType(EFFECT_TYPE_IGNITION)
	eff:SetRange(LOCATION_PZONE)
	eff:SetCountLimit(1,tables.hopt)
	eff:SetTarget(YuYuYu.DestroyPendulumEffectTarget(tables))
	eff:SetOperation(YuYuYu.DestroyPendulumEffectOperation(tables))
	return eff
end
function YuYuYu.DestroyPendulumEffectTarget(tables)
    return function(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then
            return e:GetHandler():IsDestructable() and tables.target(e,tp,eg,ep,ev,re,r,rp,0)
        end
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
        tables.setoperationinfo(e,tp,eg,ep,ev,re,r,rp)
    end
end

function YuYuYu.DestroyPendulumEffectOperation(tables)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
            tables.effect(e,tp)
        end
    end
end

function YuYuYu.DestroyEffect(c,string,tables)
    local eff=Effect.CreateEffect(c)
	eff:SetDescription(string)
    if tables.category~=nil then eff:SetCategory(tables.category) end
    if tables.force==true then
	    eff:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    else 
	    eff:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    end
	eff:SetCode(EVENT_DESTROYED)
	eff:SetCountLimit(1,{tables.hopt,2})
	eff:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	eff:SetCondition(YuYuYu.DestroyEffectCondition)
	eff:SetTarget(tables.target)
	eff:SetOperation(tables.operation)
	return eff
end
function YuYuYu.DestroyEffectCondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp~=tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
end