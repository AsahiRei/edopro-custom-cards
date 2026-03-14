--scripted by AsahiRei
local s,id=GetID()
function s.initial_effect(c)
    --pendulum summon
    Pendulum.AddProcedure(c)
    --search & tohand
    c:RegisterEffect(YuYuYu.DestroyPendulumEffect(c,aux.Stringid(id,0),{category=CATEGORY_TOHAND+CATEGORY_SEARCH,hopt=id,target=s.thtg1,effect=s.thop1,setoperationinfo=s.opinfo}))
    c:RegisterEffect(YuYuYu.DestroyEffect(c,aux.Stringid(id,1),{category=CATEGORY_TOHAND,hopt=id,target=s.thtg,operation=s.thop}))
    --indescount
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(s.indvalue)
	e1:SetTarget(s.indfilter)
	c:RegisterEffect(e1)
end
s.listed_series={SETCARD_YUYUYU}
function s.indvalue(e,re,r,rp)
	return r&REASON_BATTLE==REASON_BATTLE
end
function s.indfilter(e,c)
	return c:IsSetCard(SETCARD_YUYUYU)
end
function s.thfilter1(c)
	return not c:IsRitualSpell() and c:IsSpellTrap() and c:IsSetCard(SETCARD_YUYUYU) and c:IsAbleToHand()
end
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
end
function s.opinfo(e,tp,eg,ep,ev,re,r,rp)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop1(e,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

Duel.LoadScript("yuyuyu-utility.lua")