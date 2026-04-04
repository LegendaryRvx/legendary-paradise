print("[LP] v2.5 loading...")
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local WS=game:GetService("Workspace")
local LP=Players.LocalPlayer
local DL={}
local function dlog(m) local s="["..string.format("%.1f",os.clock()).."] "..tostring(m);table.insert(DL,s);print("[LP] "..tostring(m)) end
dlog("=== LP v2.5 ===")
local Items,Cases,LevelCalc,Rarities,UpgMod
pcall(function()
 local M=RS:FindFirstChild("Modules") or RS:WaitForChild("Modules",3)
 if M then
  pcall(function() Items=require(M:WaitForChild("Items",3)) end)
  pcall(function() Cases=require(M:WaitForChild("Cases",3)) end)
  pcall(function() LevelCalc=require(M:WaitForChild("LevelCalculator",3)) end)
  pcall(function() Rarities=require(M:WaitForChild("Rarities",3)) end)
  pcall(function() UpgMod=require(M:WaitForChild("Upgrader",3)) end)
  dlog("Modules OK")
 else dlog("NO Modules") end
end)
local Rem=RS:FindFirstChild("Remotes") or RS:WaitForChild("Remotes",5)
local ocR,slR,exR,cbR,abR,upR,urR,ccR,clR
if Rem then
 ocR=Rem:FindFirstChild("OpenCase")
 slR=Rem:FindFirstChild("Sell")
 exR=Rem:FindFirstChild("ExchangeEvent")
 cbR=Rem:FindFirstChild("CreateBattle")
 abR=Rem:FindFirstChild("AddBot")
 upR=Rem:FindFirstChild("Upgrade")
 urR=Rem:FindFirstChild("UpdateRewards")
 ccR=Rem:FindFirstChild("CheckCooldown")
 clR=Rem:FindFirstChild("ClaimLevelReward") or Rem:FindFirstChild("ClaimReward") or Rem:FindFirstChild("CollectLevelReward")
 dlog("Remotes OK CC="..(ccR and ccR.ClassName or "X").." CL="..(clR and clR.ClassName or "X"))
end
local function gInv()
 local pd=LP:FindFirstChild("PlayerData")
 if not pd then return nil end
 return pd:FindFirstChild("Inventory")
end
local function gBal()
 local pd=LP:FindFirstChild("PlayerData")
 if not pd then return 0 end
 local c=pd:FindFirstChild("Currencies")
 if not c then return 0 end
 local b=c:FindFirstChild("Balance")
 return b and b.Value or 0
end
local function gLvl()
 if not LevelCalc or not LevelCalc.CalculateLevel then return 0 end
 local pd=LP:FindFirstChild("PlayerData")
 if not pd then return 0 end
 local c=pd:FindFirstChild("Currencies")
 if not c then return 0 end
 local e=c:FindFirstChild("Experience")
 if not e then return 0 end
 local ok,d=pcall(function() return LevelCalc.CalculateLevel(e.Value) end)
 if ok and d then return d.Level or 0 end
 return 0
end
local function gPrice(item)
 if not Items then return 0 end
 local ok,d=pcall(function() return Items[item.Name] end)
 if not ok or not d or not d.Wears then return 0 end
 local w=nil;pcall(function() w=item:GetAttribute("Wear") end)
 local stt=false;pcall(function() stt=item:GetAttribute("Stattrak")==true end)
 if not w or not d.Wears[w] then for wn in pairs(d.Wears) do w=wn;break end end
 if not w or not d.Wears[w] then return 0 end
 local wd=d.Wears[w]
 if stt then return wd.StatTrak or wd.Normal or 0 else return wd.Normal or wd.StatTrak or 0 end
end
local function getWear(item) local w=nil;pcall(function() w=item:GetAttribute("Wear") end);return w end
local function getST(item) local s=false;pcall(function() s=item:GetAttribute("Stattrak")==true end);return s end
local function getUUID(item) local u=nil;pcall(function() u=item:GetAttribute("UUID") end);return u end
local function getItemAttrs(item)
 local t={};pcall(function() for k,v in pairs(item:GetAttributes()) do t[k]=v end end);return t
end
local spyLog={}
pcall(function()
 local mt=getrawmetatable(game)
 if mt and setreadonly then
  setreadonly(mt,false)
  local oldNC=mt.__namecall
  mt.__namecall=newcclosure(function(self,...)
   local method=getnamecallmethod()
   if (method=="InvokeServer" or method=="FireServer") and self.Parent==Rem then
    local args={...}
    local aStr={}
    for _,a in ipairs(args) do
     if type(a)=="table" then
      local ts={};for k,v in pairs(a) do
       if type(v)=="table" then table.insert(ts,tostring(k).."=tbl{"..#v.."}")
       else table.insert(ts,tostring(k).."="..tostring(v)) end
      end
      table.insert(aStr,"t{"..table.concat(ts,", ").."}")
     else table.insert(aStr,type(a)..":"..tostring(a)) end
    end
    local entry=self.Name.."."..method.."("..table.concat(aStr,", ")..")"
    table.insert(spyLog,entry);dlog("[SPY] "..entry)
   end
   return oldNC(self,...)
  end)
  setreadonly(mt,true)
  dlog("SPY hooked")
 else dlog("SPY: no rawmetatable") end
end)
dlog("--- Inv ---")
pcall(function()
 local inv=gInv()
 if inv then
  local ch=inv:GetChildren();dlog("Inv: "..#ch.." items")
  for i=1,math.min(5,#ch) do
   local it=ch[i];dlog("  "..it.Name.." $"..gPrice(it).." UUID="..tostring(getUUID(it)).." W="..(getWear(it) or "?").." ST="..tostring(getST(it)).." Lk="..tostring(it:GetAttribute("Locked") or false))
  end
 else dlog("No inv") end
end)
local GC=nil
if Cases then
 for id,d in pairs(Cases) do
  if type(d)=="table" then
   if d.GroupOnly==true then GC=id;break end
   if d.Name and string.lower(tostring(d.Name)):find("group") then GC=id;break end
  end
 end
end
dlog("GC="..(GC and tostring(GC) or "nil").." Bal="..tostring(gBal()).." Lv="..tostring(gLvl()))
_G.LP_FARM=false;_G.LP_SELL=false;_G.LP_EVENT=false;_G.LP_LEVEL=false
_G.LP_EXCHANGE=false;_G.LP_GIFTS=false;_G.LP_UPGRADER=false
_G.LP_ANTIAFK=false;_G.LP_AUTOBATTLE=false;_G.LP_LEVELREWARDS=false
_G.LP_XPFARM=false
_G.LP_FARM_CASE=GC or "Free"
_G.LP_SELL_MAX=50;_G.LP_KEEP_ABOVE_PRICE=500
_G.LP_UPGRADER_MIN_PRICE=0;_G.LP_UPGRADER_MAX_PRICE=50;_G.LP_UPGRADER_MULT=2;_G.LP_UPGRADER_MAX_MONEY=5000
_G.LP_BATTLE_BUDGET=500;_G.LP_BATTLE_MIN_BAL=100
_G.LP_BATTLE_MODE="CRAZY TERMINAL";_G.LP_BATTLE_CASES={}
_G.LP_XP_BUDGET=500;_G.LP_XP_CASE=nil;_G.LP_XP_QTY=5;_G.LP_XP_EARN_TARGET=500;_G.LP_XP_EARN_CASE=GC or "Free"
local st={sessions=0,casesOpened=0,earned=0,sold=0,upgAttempts=0,upgWins=0,upgLosses=0,upgProfit=0,upgSpent=0,battlesPlayed=0,battlesWon=0,battlesLost=0,battleProfit=0,xpSpent=0,xpCases=0,xpEarned=0,xpPhase="idle",xpW=0,xpL=0}
local function openCase(cid,qty)
 if not ocR then return false end
 qty=qty or 1
 local ok,r=pcall(function() return ocR:InvokeServer(cid,qty,false,false) end)
 dlog("OC("..tostring(cid).."x"..qty.."): ok="..tostring(ok).." r="..tostring(r))
 return ok and r~=false
end
local function buildSellEntry(item)
 local a=getItemAttrs(item)
 return {Name=item.Name,UUID=a.UUID,Wear=a.Wear,Stattrak=a.Stattrak or false,TimeObtained=a.TimeObtained or 0,Serial=a.Serial or 0,Numbered=a.Numbered or false,Locked=a.Locked or false,Escrow=a.Escrow or false,JackpotEscrow=a.JackpotEscrow or false,JackpotRoundId=a.JackpotRoundId or ""}
end
local function sellItems(items)
 if not slR then return false end
 local batch={}
 for _,item in ipairs(items) do table.insert(batch,buildSellEntry(item)) end
 local ok,r=pcall(function() return slR:InvokeServer(batch) end)
 dlog("Sell("..#batch.."): ok="..tostring(ok).." r="..tostring(r))
 return ok
end
local function sellOne(item)
 return sellItems({item})
end
local function findUpgradeTarget(srcPrice,mult)
 if not Items then return nil end
 local tp=srcPrice*mult;local bestK,bestN,bestW,bestP,bestST,bestDiff=nil,nil,nil,nil,false,math.huge
 for key,data in pairs(Items) do
  if type(data)=="table" and data.Wears then
   local name=data.Name or key
   for wn,wd in pairs(data.Wears) do
    if wd.Normal and wd.Normal>0 then
     local d=math.abs(wd.Normal-tp);if d<bestDiff then bestK=key;bestN=name;bestW=wn;bestP=wd.Normal;bestST=false;bestDiff=d end
    end
    if wd.StatTrak and wd.StatTrak>0 then
     local d=math.abs(wd.StatTrak-tp);if d<bestDiff then bestK=key;bestN=name;bestW=wn;bestP=wd.StatTrak;bestST=true;bestDiff=d end
    end
   end
  end
 end
 if bestK then return {Key=bestK,Instance=bestN,Name=bestN,Wear=bestW,Price=bestP,Stattrak=bestST} end
 return nil
end
local function doUpgrade(item,mult)
 if not upR then return false,"no upR" end
 local p=gPrice(item);if p<=0 then return false,"no price" end
 local target=findUpgradeTarget(p,mult)
 if not target then return false,"no target" end
 local entry=buildSellEntry(item)
 dlog("Upg: "..item.Name.." $"..p.." x"..mult.." -> "..target.Name.." $"..target.Price)
 local ok,r=pcall(function() upR:FireServer({entry},target) end)
 dlog("  FireServer: ok="..tostring(ok).." r="..tostring(r))
 return ok,r
end
pcall(function()
 if game:GetService("CoreGui"):FindFirstChild("LegendaryParadiseUI") then game:GetService("CoreGui").LegendaryParadiseUI:Destroy() end
 if LP.PlayerGui:FindFirstChild("LegendaryParadiseUI") then LP.PlayerGui.LegendaryParadiseUI:Destroy() end
end)
local sg=Instance.new("ScreenGui");sg.Name="LegendaryParadiseUI"
pcall(function() sg.ResetOnSpawn=false end)
pcall(function() sg.Parent=game:GetService("CoreGui") end)
if not sg.Parent then pcall(function() sg.Parent=LP.PlayerGui end) end
local C={bg=Color3.fromRGB(12,12,16),sb=Color3.fromRGB(18,18,22),tb=Color3.fromRGB(20,20,26),cd=Color3.fromRGB(22,22,28),ac=Color3.fromRGB(255,185,0),ton=Color3.fromRGB(0,170,90),tof=Color3.fromRGB(55,55,62),tx=Color3.fromRGB(210,210,215),td=Color3.fromRGB(120,120,130),tw=Color3.fromRGB(255,255,255),rd=Color3.fromRGB(220,50,50),bl=Color3.fromRGB(0,140,230),pu=Color3.fromRGB(160,0,220),or2=Color3.fromRGB(230,120,0),gn=Color3.fromRGB(0,180,80),lb=Color3.fromRGB(8,8,10)}
local mn=Instance.new("Frame");mn.Name="Main";mn.Size=UDim2.new(0,500,0,400);mn.Position=UDim2.new(0.5,-250,0.5,-200);mn.BackgroundColor3=C.bg;mn.BorderSizePixel=0
pcall(function() mn.Active=true end);pcall(function() mn.Draggable=true end)
mn.Parent=sg;pcall(function() Instance.new("UICorner",mn).CornerRadius=UDim.new(0,10) end)
local topb=Instance.new("Frame");topb.Size=UDim2.new(1,0,0,30);topb.BackgroundColor3=C.tb;topb.BorderSizePixel=0;topb.Parent=mn
pcall(function() Instance.new("UICorner",topb).CornerRadius=UDim.new(0,10) end)
local tbf=Instance.new("Frame",topb);tbf.Size=UDim2.new(1,0,0,10);tbf.Position=UDim2.new(0,0,1,-10);tbf.BackgroundColor3=C.tb;tbf.BorderSizePixel=0
local tl=Instance.new("TextLabel");tl.Size=UDim2.new(1,-70,1,0);tl.Position=UDim2.new(0,10,0,0);tl.BackgroundTransparency=1;tl.Text="LP v2.5";tl.TextColor3=C.ac;tl.TextSize=12;tl.Font=Enum.Font.GothamBold;tl.TextXAlignment=Enum.TextXAlignment.Left;tl.Parent=topb
local xb=Instance.new("TextButton");xb.Size=UDim2.new(0,24,0,20);xb.Position=UDim2.new(1,-30,0,5);xb.BackgroundColor3=C.rd;xb.Text="X";xb.TextColor3=C.tw;xb.TextSize=11;xb.Font=Enum.Font.GothamBold;xb.BorderSizePixel=0;xb.Parent=topb
pcall(function() Instance.new("UICorner",xb).CornerRadius=UDim.new(0,5) end)
xb.MouseButton1Click:Connect(function() sg:Destroy() end)
local mmb=Instance.new("TextButton");mmb.Size=UDim2.new(0,24,0,20);mmb.Position=UDim2.new(1,-58,0,5);mmb.BackgroundColor3=Color3.fromRGB(55,55,60);mmb.Text="_";mmb.TextColor3=C.tx;mmb.TextSize=11;mmb.Font=Enum.Font.GothamBold;mmb.BorderSizePixel=0;mmb.Parent=topb
pcall(function() Instance.new("UICorner",mmb).CornerRadius=UDim.new(0,5) end)
local bf=Instance.new("Frame");bf.Size=UDim2.new(1,0,1,-30);bf.Position=UDim2.new(0,0,0,30);bf.BackgroundTransparency=1;bf.Parent=mn
mmb.MouseButton1Click:Connect(function() bf.Visible=not bf.Visible;mn.Size=bf.Visible and UDim2.new(0,500,0,400) or UDim2.new(0,500,0,30) end)
local sbar=Instance.new("Frame");sbar.Size=UDim2.new(0,85,1,0);sbar.BackgroundColor3=C.sb;sbar.BorderSizePixel=0;sbar.Parent=bf
pcall(function() Instance.new("UICorner",sbar).CornerRadius=UDim.new(0,8) end)
local ca=Instance.new("Frame");ca.Size=UDim2.new(1,-90,1,-4);ca.Position=UDim2.new(0,88,0,2);ca.BackgroundTransparency=1;ca.Parent=bf
local tP,tB,aT={},{},nil
local tD={{"Dash"},{"Auto"},{"Battle"},{"Upgr"},{"Exploit"},{"Debug"},{"Config"}}
local function swT(n) aT=n;for k,p in pairs(tP) do p.Visible=(k==n) end;for k,b in pairs(tB) do if k==n then b.BackgroundColor3=C.ac;b.TextColor3=Color3.fromRGB(0,0,0) else b.BackgroundColor3=Color3.fromRGB(30,30,36);b.TextColor3=C.tx end end end
for i,d in ipairs(tD) do
 local b=Instance.new("TextButton");b.Size=UDim2.new(1,-8,0,22);b.Position=UDim2.new(0,4,0,3+(i-1)*26);b.BackgroundColor3=Color3.fromRGB(30,30,36);b.Text=d[1];b.TextColor3=C.tx;b.TextSize=9;b.Font=Enum.Font.GothamBold;b.BorderSizePixel=0;b.Parent=sbar
 pcall(function() Instance.new("UICorner",b).CornerRadius=UDim.new(0,6) end)
 tB[d[1]]=b;b.MouseButton1Click:Connect(function() swT(d[1]) end)
end
for _,d in ipairs(tD) do
 local s=Instance.new("ScrollingFrame");s.Size=UDim2.new(1,0,1,0);s.BackgroundTransparency=1;s.BorderSizePixel=0;s.ScrollBarThickness=4;s.ScrollBarImageColor3=C.ac;s.CanvasSize=UDim2.new(0,0,0,2000);s.Visible=false;s.Parent=ca
 local l=Instance.new("UIListLayout");l.SortOrder=Enum.SortOrder.LayoutOrder;l.Padding=UDim.new(0,3);l.Parent=s
 pcall(function() l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() s.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+10) end) end)
 local p=Instance.new("UIPadding");p.PaddingLeft=UDim.new(0,3);p.PaddingRight=UDim.new(0,3);p.PaddingTop=UDim.new(0,3);p.Parent=s
 tP[d[1]]=s
end
local function mSec(p,t,o) local l=Instance.new("TextLabel");l.Size=UDim2.new(1,0,0,16);l.BackgroundTransparency=1;l.Text="-- "..t.." --";l.TextColor3=C.ac;l.TextSize=9;l.Font=Enum.Font.GothamBold;l.LayoutOrder=o or 0;l.Parent=p end
local function mLbl(p,t,o) local l=Instance.new("TextLabel");l.Size=UDim2.new(1,0,0,14);l.BackgroundTransparency=1;l.Text=t;l.TextColor3=C.tx;l.TextSize=9;l.Font=Enum.Font.Gotham;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextWrapped=true;l.LayoutOrder=o or 0;l.Parent=p;return l end
local function mTog(p,lt,fl,co,o)
 local r=Instance.new("Frame");r.Size=UDim2.new(1,0,0,24);r.BackgroundColor3=C.cd;r.BorderSizePixel=0;r.LayoutOrder=o or 0;r.Parent=p
 pcall(function() Instance.new("UICorner",r).CornerRadius=UDim.new(0,6) end)
 local l=Instance.new("TextLabel");l.Size=UDim2.new(1,-50,1,0);l.Position=UDim2.new(0,6,0,0);l.BackgroundTransparency=1;l.Text=lt;l.TextColor3=C.tx;l.TextSize=9;l.Font=Enum.Font.Gotham;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=r
 local b=Instance.new("TextButton");b.Size=UDim2.new(0,38,0,16);b.Position=UDim2.new(1,-42,0.5,-8);b.BorderSizePixel=0;b.TextSize=9;b.Font=Enum.Font.GothamBold;b.Parent=r
 pcall(function() Instance.new("UICorner",b).CornerRadius=UDim.new(0,5) end)
 local function rf() if _G[fl] then b.BackgroundColor3=co or C.ton;b.Text="ON";b.TextColor3=C.tw else b.BackgroundColor3=C.tof;b.Text="OFF";b.TextColor3=C.td end end
 b.MouseButton1Click:Connect(function() _G[fl]=not _G[fl];rf();dlog(fl.."="..((_G[fl]) and "ON" or "OFF")) end);rf()
end
local function mBtn(p,t,c,cb,o) local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,24);b.BackgroundColor3=c or C.bl;b.Text=t;b.TextColor3=C.tw;b.TextSize=9;b.Font=Enum.Font.GothamBold;b.BorderSizePixel=0;b.LayoutOrder=o or 0;b.Parent=p;pcall(function() Instance.new("UICorner",b).CornerRadius=UDim.new(0,6) end);b.MouseButton1Click:Connect(cb);return b end
local function mInput(p,lbl,def,gkey,o)
 local r=Instance.new("Frame");r.Size=UDim2.new(1,0,0,22);r.BackgroundColor3=C.cd;r.BorderSizePixel=0;r.LayoutOrder=o or 0;r.Parent=p
 pcall(function() Instance.new("UICorner",r).CornerRadius=UDim.new(0,6) end)
 local l=Instance.new("TextLabel");l.Size=UDim2.new(0,95,1,0);l.Position=UDim2.new(0,6,0,0);l.BackgroundTransparency=1;l.Text=lbl;l.TextColor3=C.tx;l.TextSize=9;l.Font=Enum.Font.Gotham;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=r
 local tb2=Instance.new("TextBox");tb2.Size=UDim2.new(1,-103,1,-4);tb2.Position=UDim2.new(0,99,0,2);tb2.BackgroundColor3=Color3.fromRGB(30,30,36);tb2.Text=tostring(def);tb2.TextColor3=C.ac;tb2.TextSize=9;tb2.Font=Enum.Font.GothamBold;tb2.BorderSizePixel=0;tb2.ClearTextOnFocus=false;tb2.Parent=r
 pcall(function() Instance.new("UICorner",tb2).CornerRadius=UDim.new(0,4) end)
 tb2.FocusLost:Connect(function() _G[gkey]=tonumber(tb2.Text) or def end)
 return tb2
end
local logQ,logLbl={},nil
local function log(m) dlog(m);table.insert(logQ,tostring(m));if #logQ>10 then table.remove(logQ,1) end;if logLbl then logLbl.Text=table.concat(logQ,"\n") end end
pcall(function()
 local pg=tP["Dash"]
 mSec(pg,"LEGENDARY PARADISE v2.5",1)
 mSec(pg,"PLAYER",3);local il=mLbl(pg,"...",4)
 mSec(pg,"STATS",7);local sl=mLbl(pg,"...",8)
 mSec(pg,"LIVE LOG",9)
 local lb=Instance.new("Frame");lb.Size=UDim2.new(1,0,0,120);lb.BackgroundColor3=C.lb;lb.BorderSizePixel=0;lb.LayoutOrder=10;lb.Parent=pg
 pcall(function() Instance.new("UICorner",lb).CornerRadius=UDim.new(0,6) end)
 logLbl=Instance.new("TextLabel");logLbl.Size=UDim2.new(1,-6,1,-4);logLbl.Position=UDim2.new(0,3,0,2);logLbl.BackgroundTransparency=1;logLbl.Text="...";logLbl.TextColor3=Color3.fromRGB(160,220,160);logLbl.TextSize=8;logLbl.Font=Enum.Font.Code;logLbl.TextXAlignment=Enum.TextXAlignment.Left;logLbl.TextYAlignment=Enum.TextYAlignment.Top;logLbl.TextWrapped=true;logLbl.Parent=lb
 coroutine.resume(coroutine.create(function() while wait(2) do pcall(function()
  il.Text="Lv:"..tostring(gLvl()).." $"..tostring(math.floor(gBal()))
  local xpS="";if _G.LP_XPFARM then xpS=" | XP:"..st.xpPhase.." $"..math.floor(st.xpSpent).."/$".._G.LP_XP_BUDGET end
  sl.Text="S:"..st.sessions.." C:"..st.casesOpened.." Sold:"..st.sold.." $"..math.floor(st.earned)..xpS
 end) end end))
end)
pcall(function()
 local pg=tP["Auto"]
 mSec(pg,"AUTO FARM",1);mTog(pg,"Auto Farm","LP_FARM",C.bl,2)
 local fcl=mLbl(pg,"Case: "..tostring(_G.LP_FARM_CASE),3);fcl.TextColor3=C.ac
 local acn={}
 if Cases then for id,d in pairs(Cases) do if type(d)=="table" and d.Name then table.insert(acn,{id=id,name=d.Name,price=d.Price or 0}) end end;table.sort(acn,function(a,b) return a.price<b.price end) end
 local fcf=Instance.new("Frame");fcf.Size=UDim2.new(1,0,0,65);fcf.BackgroundColor3=Color3.fromRGB(15,15,19);fcf.BorderSizePixel=0;fcf.LayoutOrder=4;fcf.Parent=pg
 pcall(function() Instance.new("UICorner",fcf).CornerRadius=UDim.new(0,6) end)
 local fcs=Instance.new("ScrollingFrame");fcs.Size=UDim2.new(1,-4,1,-4);fcs.Position=UDim2.new(0,2,0,2);fcs.BackgroundTransparency=1;fcs.BorderSizePixel=0;fcs.ScrollBarThickness=3;fcs.CanvasSize=UDim2.new(0,0,0,#acn*18+8);fcs.Parent=fcf
 local fcL=Instance.new("UIListLayout");fcL.SortOrder=Enum.SortOrder.LayoutOrder;fcL.Padding=UDim.new(0,1);fcL.Parent=fcs
 local fcBs={}
 for idx,e in ipairs(acn) do
  local sel=(e.id==_G.LP_FARM_CASE)
  local fb=Instance.new("TextButton");fb.Size=UDim2.new(1,-4,0,16);fb.BackgroundColor3=sel and C.ac or C.cd;fb.Text=e.name..(e.price>0 and(" $"..e.price) or " FREE");fb.TextColor3=sel and Color3.fromRGB(0,0,0) or C.tx;fb.TextSize=8;fb.Font=Enum.Font.Gotham;fb.TextXAlignment=Enum.TextXAlignment.Left;fb.BorderSizePixel=0;fb.LayoutOrder=idx;fb.Parent=fcs
  pcall(function() Instance.new("UICorner",fb).CornerRadius=UDim.new(0,4) end)
  fcBs[e.id]=fb
  fb.MouseButton1Click:Connect(function() _G.LP_FARM_CASE=e.id;fcl.Text="Case: "..e.name;for k,v in pairs(fcBs) do if k==e.id then v.BackgroundColor3=C.ac;v.TextColor3=Color3.fromRGB(0,0,0) else v.BackgroundColor3=C.cd;v.TextColor3=C.tx end end end)
 end
 mSec(pg,"AUTO SELL",10);mTog(pg,"Auto Sell","LP_SELL",C.or2,11)
 mInput(pg,"Keep above $",500,"LP_KEEP_ABOVE_PRICE",12)
 mInput(pg,"Max sell/cy",50,"LP_SELL_MAX",13)
 mSec(pg,"XP FARM",14);mTog(pg,"XP Farm","LP_XPFARM",Color3.fromRGB(255,50,200),15)
 local xpSl=mLbl(pg,"XP: idle | W:0 L:0 | Spent:$0",16);xpSl.TextColor3=Color3.fromRGB(255,150,220)
 mInput(pg,"Min balance $",500,"LP_XP_BUDGET",17)
 mInput(pg,"Cases/open",5,"LP_XP_QTY",18)
 mInput(pg,"Earn target $",500,"LP_XP_EARN_TARGET",19)
 local xpCl=mLbl(pg,"XP Case: (auto)",20);xpCl.TextColor3=C.ac
 local xpBs={}
 local acnXP={}
 if Cases then for id,d in pairs(Cases) do if type(d)=="table" and d.Name and d.Price and d.Price>0 and d.Price<=100 then table.insert(acnXP,{id=id,name=d.Name,price=d.Price}) end end;table.sort(acnXP,function(a,b) return a.price<b.price end) end
 if #acnXP>0 and not _G.LP_XP_CASE then _G.LP_XP_CASE=acnXP[1].id end
 xpCl.Text="XP Case: "..((_G.LP_XP_CASE and tostring(_G.LP_XP_CASE)) or "auto")
 local xpFr=Instance.new("Frame");xpFr.Size=UDim2.new(1,0,0,55);xpFr.BackgroundColor3=Color3.fromRGB(15,15,19);xpFr.BorderSizePixel=0;xpFr.LayoutOrder=21;xpFr.Parent=pg
 pcall(function() Instance.new("UICorner",xpFr).CornerRadius=UDim.new(0,6) end)
 local xpSc=Instance.new("ScrollingFrame");xpSc.Size=UDim2.new(1,-4,1,-4);xpSc.Position=UDim2.new(0,2,0,2);xpSc.BackgroundTransparency=1;xpSc.BorderSizePixel=0;xpSc.ScrollBarThickness=3;xpSc.CanvasSize=UDim2.new(0,0,0,#acnXP*18+8);xpSc.Parent=xpFr
 local xpLL=Instance.new("UIListLayout");xpLL.SortOrder=Enum.SortOrder.LayoutOrder;xpLL.Padding=UDim.new(0,1);xpLL.Parent=xpSc
 for idx,e in ipairs(acnXP) do
  local sel=(e.id==_G.LP_XP_CASE)
  local xb2=Instance.new("TextButton");xb2.Size=UDim2.new(1,-4,0,16);xb2.BackgroundColor3=sel and C.ac or C.cd;xb2.Text=e.name.." $"..e.price;xb2.TextColor3=sel and Color3.fromRGB(0,0,0) or C.tx;xb2.TextSize=8;xb2.Font=Enum.Font.Gotham;xb2.TextXAlignment=Enum.TextXAlignment.Left;xb2.BorderSizePixel=0;xb2.LayoutOrder=idx;xb2.Parent=xpSc
  pcall(function() Instance.new("UICorner",xb2).CornerRadius=UDim.new(0,4) end)
  xpBs[e.id]=xb2
  xb2.MouseButton1Click:Connect(function() _G.LP_XP_CASE=e.id;xpCl.Text="XP Case: "..e.name;for k,v in pairs(xpBs) do if k==e.id then v.BackgroundColor3=C.ac;v.TextColor3=Color3.fromRGB(0,0,0) else v.BackgroundColor3=C.cd;v.TextColor3=C.tx end end end)
 end
 local earnCl=mLbl(pg,"Earn Case: "..tostring(_G.LP_XP_EARN_CASE),22);earnCl.TextColor3=C.ac
 local earnBs={}
 local earnFr=Instance.new("Frame");earnFr.Size=UDim2.new(1,0,0,45);earnFr.BackgroundColor3=Color3.fromRGB(15,15,19);earnFr.BorderSizePixel=0;earnFr.LayoutOrder=23;earnFr.Parent=pg
 pcall(function() Instance.new("UICorner",earnFr).CornerRadius=UDim.new(0,6) end)
 local earnSc=Instance.new("ScrollingFrame");earnSc.Size=UDim2.new(1,-4,1,-4);earnSc.Position=UDim2.new(0,2,0,2);earnSc.BackgroundTransparency=1;earnSc.BorderSizePixel=0;earnSc.ScrollBarThickness=3;earnSc.CanvasSize=UDim2.new(0,0,0,#acn*18+8);earnSc.Parent=earnFr
 local earnLL=Instance.new("UIListLayout");earnLL.SortOrder=Enum.SortOrder.LayoutOrder;earnLL.Padding=UDim.new(0,1);earnLL.Parent=earnSc
 for idx,e in ipairs(acn) do
  local sel2=(e.id==_G.LP_XP_EARN_CASE)
  local eb=Instance.new("TextButton");eb.Size=UDim2.new(1,-4,0,16);eb.BackgroundColor3=sel2 and C.gn or C.cd;eb.Text=e.name..(e.price>0 and(" $"..e.price) or " FREE");eb.TextColor3=sel2 and Color3.fromRGB(0,0,0) or C.tx;eb.TextSize=8;eb.Font=Enum.Font.Gotham;eb.TextXAlignment=Enum.TextXAlignment.Left;eb.BorderSizePixel=0;eb.LayoutOrder=idx;eb.Parent=earnSc
  pcall(function() Instance.new("UICorner",eb).CornerRadius=UDim.new(0,4) end)
  earnBs[e.id]=eb
  eb.MouseButton1Click:Connect(function() _G.LP_XP_EARN_CASE=e.id;earnCl.Text="Earn Case: "..e.name;for k,v in pairs(earnBs) do if k==e.id then v.BackgroundColor3=C.gn;v.TextColor3=Color3.fromRGB(0,0,0) else v.BackgroundColor3=C.cd;v.TextColor3=C.tx end end end)
 end
 coroutine.resume(coroutine.create(function() while wait(1) do pcall(function() xpSl.Text="XP: "..st.xpPhase.." | W:"..st.xpW.." L:"..st.xpL.." | $"..math.floor(st.xpSpent).." spent | Bal:$"..math.floor(gBal()) end) end end))
 mSec(pg,"AUTO LEVEL (old)",24);mTog(pg,"Auto Level","LP_LEVEL",C.gn,25)
 mSec(pg,"EXTRAS",26);mTog(pg,"Level Rewards","LP_LEVELREWARDS",C.bl,27);mTog(pg,"Events","LP_EVENT",C.pu,28);mTog(pg,"Exchange","LP_EXCHANGE",C.gn,29);mTog(pg,"Gifts","LP_GIFTS",C.gn,30)
 mBtn(pg,"ALL ON",C.gn,function() _G.LP_FARM=true;_G.LP_SELL=true;_G.LP_EVENT=true;_G.LP_LEVEL=true;_G.LP_EXCHANGE=true;_G.LP_GIFTS=true;_G.LP_LEVELREWARDS=true;_G.LP_XPFARM=true;log("All ON");swT("Auto") end,33)
 mBtn(pg,"ALL OFF",C.rd,function() _G.LP_FARM=false;_G.LP_SELL=false;_G.LP_EVENT=false;_G.LP_LEVEL=false;_G.LP_EXCHANGE=false;_G.LP_GIFTS=false;_G.LP_LEVELREWARDS=false;_G.LP_XPFARM=false;log("All OFF");swT("Auto") end,34)
end)
pcall(function()
 local pg=tP["Battle"]
 local acn2={}
 if Cases then for id,d in pairs(Cases) do if type(d)=="table" and d.Name and d.ForBattles then table.insert(acn2,{id=id,name=d.Name,price=d.Price or 0}) end end;table.sort(acn2,function(a,b) return a.price<b.price end) end
 local bm={"CLASSIC","TERMINAL","CRAZY TERMINAL","SHARED","JESTER","JACKPOT","CRAZY JACKPOT"}
 mSec(pg,"CASES (multi)",1)
 local scl=mLbl(pg,"Selected: 0",2);scl.TextColor3=C.ac
 local function updSel() local n=0;for _ in pairs(_G.LP_BATTLE_CASES) do n=n+1 end;scl.Text="Selected: "..n end
 local clf=Instance.new("Frame");clf.Size=UDim2.new(1,0,0,90);clf.BackgroundColor3=Color3.fromRGB(15,15,19);clf.BorderSizePixel=0;clf.LayoutOrder=3;clf.Parent=pg
 pcall(function() Instance.new("UICorner",clf).CornerRadius=UDim.new(0,6) end)
 local csc=Instance.new("ScrollingFrame");csc.Size=UDim2.new(1,-4,1,-4);csc.Position=UDim2.new(0,2,0,2);csc.BackgroundTransparency=1;csc.BorderSizePixel=0;csc.ScrollBarThickness=3;csc.CanvasSize=UDim2.new(0,0,0,math.max(300,#acn2*20));csc.Parent=clf
 local cL=Instance.new("UIListLayout");cL.SortOrder=Enum.SortOrder.LayoutOrder;cL.Padding=UDim.new(0,1);cL.Parent=csc
 local cBs={}
 for idx,e in ipairs(acn2) do
  local cb=Instance.new("TextButton");cb.Size=UDim2.new(1,-4,0,18);cb.BackgroundColor3=C.cd;cb.Text=e.name.." $"..e.price;cb.TextColor3=C.tx;cb.TextSize=8;cb.Font=Enum.Font.Gotham;cb.TextXAlignment=Enum.TextXAlignment.Left;cb.BorderSizePixel=0;cb.LayoutOrder=idx;cb.Parent=csc
  pcall(function() Instance.new("UICorner",cb).CornerRadius=UDim.new(0,4) end)
  table.insert(cBs,{btn=cb,name=e.name,id=e.id})
  cb.MouseButton1Click:Connect(function()
   if _G.LP_BATTLE_CASES[e.id] then _G.LP_BATTLE_CASES[e.id]=nil;cb.BackgroundColor3=C.cd;cb.TextColor3=C.tx
   else _G.LP_BATTLE_CASES[e.id]=e.name;cb.BackgroundColor3=C.ac;cb.TextColor3=Color3.fromRGB(0,0,0) end
   updSel()
  end)
 end
 mBtn(pg,"Select ALL",C.gn,function() for _,e in ipairs(cBs) do _G.LP_BATTLE_CASES[e.id]=e.name;e.btn.BackgroundColor3=C.ac;e.btn.TextColor3=Color3.fromRGB(0,0,0) end;updSel() end,4)
 mBtn(pg,"Clear ALL",C.rd,function() _G.LP_BATTLE_CASES={};for _,e in ipairs(cBs) do e.btn.BackgroundColor3=C.cd;e.btn.TextColor3=C.tx end;updSel() end,5)
 mSec(pg,"MODE",6)
 local mf=Instance.new("Frame");mf.Size=UDim2.new(1,0,0,48);mf.BackgroundTransparency=1;mf.LayoutOrder=7;mf.Parent=pg
 local mBs={}
 for i,m in ipairs(bm) do
  local col=math.ceil(i/4);local row=((i-1)%4)
  local mb2=Instance.new("TextButton");mb2.Size=UDim2.new(0.245,-2,0,20);mb2.Position=UDim2.new(row*0.25,1,0,(col-1)*24);mb2.BackgroundColor3=(m=="CRAZY TERMINAL") and C.ac or C.cd;mb2.Text=m;mb2.TextColor3=(m=="CRAZY TERMINAL") and Color3.fromRGB(0,0,0) or C.tx;mb2.TextSize=7;mb2.Font=Enum.Font.GothamBold;mb2.BorderSizePixel=0;mb2.Parent=mf
  pcall(function() Instance.new("UICorner",mb2).CornerRadius=UDim.new(0,5) end)
  mBs[m]=mb2
  mb2.MouseButton1Click:Connect(function() _G.LP_BATTLE_MODE=m;for k,v in pairs(mBs) do if k==m then v.BackgroundColor3=C.ac;v.TextColor3=Color3.fromRGB(0,0,0) else v.BackgroundColor3=C.cd;v.TextColor3=C.tx end end end)
 end
 mBtn(pg,"CREATE BATTLE",C.bl,function()
  local cids={};for id in pairs(_G.LP_BATTLE_CASES) do table.insert(cids,tostring(id)) end
  if #cids==0 then log("Select cases!");return end
  if not cbR then log("No cbR!");return end
  local bal1=gBal()
  dlog("Battle: "..#cids.." cases mode=".._G.LP_BATTLE_MODE)
  local ok,bid=pcall(function() return cbR:InvokeServer(cids,2,_G.LP_BATTLE_MODE,false) end)
  dlog("CB: ok="..tostring(ok).." bid="..tostring(bid))
  if ok and bid and abR then
   wait(0.6);pcall(function() abR:FireServer(tonumber(bid),LP) end)
   st.battlesPlayed=st.battlesPlayed+1
   log("Battle #"..st.battlesPlayed.." waiting...")
   wait(12)
   local bal2=gBal();local diff=bal2-bal1
   if diff>0 then st.battlesWon=st.battlesWon+1;st.battleProfit=st.battleProfit+diff;log("WIN +$"..math.floor(diff))
   else st.battlesLost=st.battlesLost+1;st.battleProfit=st.battleProfit+diff;log("LOSS $"..math.floor(diff)) end
  end
 end,8)
 mSec(pg,"AUTO BATTLE",10);mTog(pg,"Auto Battle","LP_AUTOBATTLE",C.pu,11)
 mInput(pg,"Budget $",500,"LP_BATTLE_BUDGET",12)
 mInput(pg,"Min Bal $",100,"LP_BATTLE_MIN_BAL",13)
 mSec(pg,"STATS",16);local bsl=mLbl(pg,"P:0 W:0 L:0 $0",17)
 mBtn(pg,"Reset",C.rd,function() st.battlesPlayed=0;st.battlesWon=0;st.battlesLost=0;st.battleProfit=0 end,18)
 coroutine.resume(coroutine.create(function() while wait(2) do pcall(function() bsl.Text="P:"..st.battlesPlayed.." W:"..st.battlesWon.." L:"..st.battlesLost.." $"..math.floor(st.battleProfit) end) end end))
end)
pcall(function()
 local pg=tP["Upgr"]
 mSec(pg,"UPGRADER",1);mTog(pg,"Auto Upgrader","LP_UPGRADER",C.or2,2)
 mSec(pg,"MULT",4)
 local mBs2={};local mr2=Instance.new("Frame");mr2.Size=UDim2.new(1,0,0,22);mr2.BackgroundTransparency=1;mr2.LayoutOrder=5;mr2.Parent=pg
 for i,m in ipairs({2,3,5,10}) do
  local b=Instance.new("TextButton");b.Size=UDim2.new(0.24,-3,1,0);b.Position=UDim2.new((i-1)*0.25,2,0,0);b.BackgroundColor3=m==2 and C.ac or C.cd;b.Text=m.."x";b.TextColor3=m==2 and Color3.fromRGB(0,0,0) or C.tx;b.TextSize=9;b.Font=Enum.Font.GothamBold;b.BorderSizePixel=0;b.Parent=mr2
  pcall(function() Instance.new("UICorner",b).CornerRadius=UDim.new(0,5) end);mBs2[m]=b
  b.MouseButton1Click:Connect(function() _G.LP_UPGRADER_MULT=m;for k,v in pairs(mBs2) do if k==m then v.BackgroundColor3=C.ac;v.TextColor3=Color3.fromRGB(0,0,0) else v.BackgroundColor3=C.cd;v.TextColor3=C.tx end end end)
 end
 mSec(pg,"LIMITS",6)
 mInput(pg,"Max money $",5000,"LP_UPGRADER_MAX_MONEY",7)
 mInput(pg,"Min item $",0,"LP_UPGRADER_MIN_PRICE",8)
 mInput(pg,"Max item $",50,"LP_UPGRADER_MAX_PRICE",9)
 mSec(pg,"STATS",10);local us=mLbl(pg,"A:0 W:0 L:0 $0",11)
 mBtn(pg,"Reset",C.rd,function() st.upgAttempts=0;st.upgWins=0;st.upgLosses=0;st.upgProfit=0;st.upgSpent=0 end,12)
 coroutine.resume(coroutine.create(function() while wait(2) do pcall(function() us.Text="A:"..st.upgAttempts.." W:"..st.upgWins.." L:"..st.upgLosses.." $"..math.floor(st.upgProfit).." Sp:$"..math.floor(st.upgSpent) end) end end))
end)
pcall(function()
 local pg=tP["Exploit"]
 mSec(pg,"CLIENT-SIDE (visual only)",1)
 mBtn(pg,"Money $999k (visual)",C.bl,function() pcall(function() local pd=LP:FindFirstChild("PlayerData");local c=pd and pd:FindFirstChild("Currencies");local b=c and c:FindFirstChild("Balance");if b then b.Value=999999;log("$999k visual") end end) end,2)
 mBtn(pg,"Tickets 9999 (visual)",C.pu,function() pcall(function() local pd=LP:FindFirstChild("PlayerData");local c=pd and c:FindFirstChild("Currencies");local t=c and c:FindFirstChild("Tickets");if t then t.Value=9999;log("Tix visual") end end) end,3)
end)
local dbgBox
pcall(function()
 local pg=tP["Debug"]
 mSec(pg,"DEBUG LOG",1)
 mLbl(pg,"Tap box -> Select All -> Copy",2)
 local dbgF=Instance.new("Frame");dbgF.Size=UDim2.new(1,0,0,180);dbgF.BackgroundColor3=Color3.fromRGB(5,5,8);dbgF.BorderSizePixel=0;dbgF.LayoutOrder=3;dbgF.Parent=pg
 pcall(function() Instance.new("UICorner",dbgF).CornerRadius=UDim.new(0,6) end)
 dbgBox=Instance.new("TextBox");dbgBox.Size=UDim2.new(1,-6,1,-6);dbgBox.Position=UDim2.new(0,3,0,3);dbgBox.BackgroundTransparency=1;dbgBox.Text=table.concat(DL,"\n");dbgBox.TextColor3=Color3.fromRGB(0,255,100);dbgBox.TextSize=7;dbgBox.Font=Enum.Font.Code;dbgBox.TextXAlignment=Enum.TextXAlignment.Left;dbgBox.TextYAlignment=Enum.TextYAlignment.Top;dbgBox.TextWrapped=true;dbgBox.ClearTextOnFocus=false;dbgBox.MultiLine=true;dbgBox.TextEditable=false;dbgBox.Parent=dbgF
 mBtn(pg,"REFRESH",C.bl,function() dbgBox.Text=table.concat(DL,"\n") end,4)
 mBtn(pg,"Show SPY (non-Cooldown)",C.pu,function()
  dlog("=== SPY ===")
  for _,e in ipairs(spyLog) do if not string.find(e,"CheckCooldown") then dlog("[S] "..e) end end
  dlog("=== END ===");dbgBox.Text=table.concat(DL,"\n")
 end,5)
 mSec(pg,"TESTS",6)
 mBtn(pg,"TEST: Open Group case",C.gn,function()
  dlog("=== TEST OC Group ===")
  local bal1=gBal();local invB=0;pcall(function() invB=#gInv():GetChildren() end)
  openCase("Group")
  wait(1)
  local bal2=gBal();local invA=0;pcall(function() invA=#gInv():GetChildren() end)
  dlog("Bal:"..bal1.."->"..bal2.." Inv:"..invB.."->"..invA)
  dlog("=== END ===");dbgBox.Text=table.concat(DL,"\n")
 end,7)
 mBtn(pg,"TEST: Open Free case",C.gn,function()
  dlog("=== TEST OC Free ===")
  local bal1=gBal();local invB=0;pcall(function() invB=#gInv():GetChildren() end)
  openCase("Free")
  wait(1)
  local bal2=gBal();local invA=0;pcall(function() invA=#gInv():GetChildren() end)
  dlog("Bal:"..bal1.."->"..bal2.." Inv:"..invB.."->"..invA)
  dlog("=== END ===");dbgBox.Text=table.concat(DL,"\n")
 end,8)
 mBtn(pg,"TEST: Sell cheapest (table)",C.or2,function()
  dlog("=== TEST SELL ===")
  local inv=gInv();if not inv then dlog("No inv");dbgBox.Text=table.concat(DL,"\n");return end
  local best=nil;local bp=math.huge
  for _,it in ipairs(inv:GetChildren()) do
   if not it:GetAttribute("Locked") then local p=gPrice(it);if p>0 and p<bp then bp=p;best=it end end
  end
  if not best then dlog("No unlocked item");dbgBox.Text=table.concat(DL,"\n");return end
  dlog("Target: "..best.Name.." $"..bp.." UUID="..tostring(getUUID(best)))
  local entry=buildSellEntry(best)
  local eStr={};for k,v in pairs(entry) do table.insert(eStr,k.."="..tostring(v)) end
  dlog("Entry: "..table.concat(eStr,", "))
  local bal1=gBal();local invB=#inv:GetChildren()
  local ok,r=pcall(function() return slR:InvokeServer({entry}) end)
  dlog("Sell({entry}): ok="..tostring(ok).." r="..tostring(r))
  wait(0.5)
  local bal2=gBal();local invA=#inv:GetChildren()
  dlog("Bal:"..bal1.."->"..bal2.." Inv:"..invB.."->"..invA)
  if bal2>bal1 or invA<invB then dlog(">> SELL WORKED!") else
   dlog("Trying alt patterns...")
   local ok2,r2=pcall(function() return slR:InvokeServer({{UUID=getUUID(best)}}) end)
   dlog("S({UUID}): ok="..tostring(ok2).." r="..tostring(r2))
   wait(0.5);local bal3=gBal();local invA2=#inv:GetChildren()
   dlog("Bal:"..bal2.."->"..bal3.." Inv:"..invA.."->"..invA2)
   if bal3>bal2 or invA2<invA then dlog(">> UUID-only WORKED!") else
    local ok3,r3=pcall(function() return slR:InvokeServer({{Name=best.Name,Wear=getWear(best),UUID=getUUID(best),Stattrak=getST(best)}}) end)
    dlog("S({N,W,U,S}): ok="..tostring(ok3).." r="..tostring(r3))
    wait(0.5);local bal4=gBal();local invA3=#inv:GetChildren()
    dlog("Bal:"..bal3.."->"..bal4.." Inv:"..invA2.."->"..invA3)
    if bal4>bal3 or invA3<invA2 then dlog(">> N,W,U,S WORKED!") else dlog("ALL SELL FAILED") end
   end
  end
  dlog("=== END ===");dbgBox.Text=table.concat(DL,"\n")
 end,9)
 mBtn(pg,"TEST: Upgrade cheapest",C.pu,function()
  dlog("=== TEST UPGRADE ===")
  if not upR then dlog("No upR");dbgBox.Text=table.concat(DL,"\n");return end
  local inv=gInv();if not inv then dlog("No inv");dbgBox.Text=table.concat(DL,"\n");return end
  local best=nil;local bp=math.huge
  for _,it in ipairs(inv:GetChildren()) do if not it:GetAttribute("Locked") then local p=gPrice(it);if p>0 and p<bp then bp=p;best=it end end end
  if not best then dlog("No item");dbgBox.Text=table.concat(DL,"\n");return end
  dlog("Upg: "..best.Name.." $"..bp)
  local bal1=gBal();local invB=#inv:GetChildren()
  local m=_G.LP_UPGRADER_MULT or 2
  local ok,r=doUpgrade(best,m)
  dlog("Result: ok="..tostring(ok).." r="..tostring(r))
  wait(1.5)
  local bal2=gBal();local invA=#inv:GetChildren()
  dlog("Bal:"..bal1.."->"..bal2.." Inv:"..invB.."->"..invA)
  dlog("=== END ===");dbgBox.Text=table.concat(DL,"\n")
 end,10)
 mBtn(pg,"DUMP: Spy (filtered)",C.or2,function()
  dlog("=== FILTERED SPY ===")
  for _,e in ipairs(spyLog) do if not string.find(e,"CheckCooldown") then dlog(e) end end
  dlog("=== END ===");dbgBox.Text=table.concat(DL,"\n")
 end,11)
 mBtn(pg,"CLEAR",C.rd,function() DL={};spyLog={};dlog("Cleared");dbgBox.Text="" end,12)
end)
pcall(function()
 local pg=tP["Config"]
 mSec(pg,"GENERAL",1);mTog(pg,"Anti-AFK","LP_ANTIAFK",C.gn,2)
 mSec(pg,"INFO",4);mLbl(pg,"LP v2.5 - LegendaryRvx",5)
 mLbl(pg,"OC=InvokeServer(caseId,1,false,false)",6)
 mLbl(pg,"Sell=InvokeServer({itemTable,...})",7)
 mBtn(pg,"Destroy GUI",C.rd,function() sg:Destroy() end,9)
end)
swT("Dash")
log("v2.5 loaded $"..math.floor(gBal()).." Lv"..tostring(gLvl()))
log("Farm: "..tostring(_G.LP_FARM_CASE))
local lvlCases={"LEVEL10","LEVEL20","LEVEL30","LEVEL40","LEVEL50","LEVEL60","LEVEL70","LEVEL80","LEVEL90","LEVELS100","LEVELS110","LEVELS120"}
local lvlClaimed={}
local function quickSell()
 if not slR then return end
 pcall(function()
  local inv=gInv();if not inv then return end
  local kp=_G.LP_KEEP_ABOVE_PRICE or 500;local batch={}
  for _,it in ipairs(inv:GetChildren()) do
   if #batch>=30 then break end
   if not it:GetAttribute("Locked") then local p=gPrice(it);if p>0 and p<kp then table.insert(batch,it) end end
  end
  if #batch>0 then
   local entries={};for _,item in ipairs(batch) do table.insert(entries,buildSellEntry(item)) end
   pcall(function() slR:InvokeServer(entries) end)
   st.sold=st.sold+#batch
  end
 end)
end
local lvlThresholds={LEVEL10=10,LEVEL20=20,LEVEL30=30,LEVEL40=40,LEVEL50=50,LEVEL60=60,LEVEL70=70,LEVEL80=80,LEVEL90=90,LEVELS100=100,LEVELS110=110,LEVELS120=120}
local lvlCooldowns={} -- lv -> os.time() when cooldown expires
_G.LP_LEVEL_ACTIVE=false
-- === PRIORITY ENGINE ===
-- P0: Level rewards - checks level, scans all eligible cases, pauses farm during cycle
coroutine.resume(coroutine.create(function()
 while wait(10) do
  if _G.LP_LEVELREWARDS and ocR and ccR then
   pcall(function()
    local pLvl=gLvl()
    local now=os.time()
    -- Build eligible list (only levels <= player level)
    local eligible={}
    for _,lv in ipairs(lvlCases) do
     local req=lvlThresholds[lv] or 999
     if req<=pLvl then table.insert(eligible,lv) end
    end
    if #eligible==0 then dlog("LVL: no eligible (lv"..tostring(pLvl)..")");return end
    -- First pass: check all cooldowns silently
    local ready={}
    for _,lv in ipairs(eligible) do
     local cdEnd=lvlCooldowns[lv] or 0
     if cdEnd>now then
      local left=math.floor(cdEnd-now)
      dlog("LVL "..lv..": "..left.."s left")
     else
      -- Ask server for cooldown
      local ok2,r2=pcall(function() return ccR:InvokeServer(lv) end)
      dlog("LVL CC("..lv.."): "..tostring(r2).." ("..type(r2)..")")
      if ok2 and type(r2)=="number" and r2>now then
       lvlCooldowns[lv]=r2
       dlog("  "..lv..": "..math.floor(r2-now).."s left")
      elseif ok2 and (r2==0 or r2==true or r2==false or (type(r2)=="number" and r2<=now)) then
       table.insert(ready,lv)
      else
       lvlCooldowns[lv]=now+120 -- unknown, retry in 2min
      end
      wait(0.5)
     end
    end
    if #ready==0 then dlog("LVL: all "..#eligible.." on cooldown");return end
    -- Pause farm and open ready cases one by one
    log("LVL: "..#ready.." cases ready, pausing farm...")
    _G.LP_LEVEL_ACTIVE=true
    wait(2) -- let current farm cycle finish
    for i,lv in ipairs(ready) do
     if not _G.LP_LEVELREWARDS then break end
     -- Re-check level (might have leveled up)
     local curLvl=gLvl()
     local req=lvlThresholds[lv] or 999
     if req>curLvl then dlog("LVL skip "..lv.." (leveled?)");break end
     log("LVL opening "..lv.." ("..i.."/"..#ready..")")
     local ok,r=pcall(function() return ocR:InvokeServer(lv,1,false,false) end)
     dlog("  OC("..lv.."): ok="..tostring(ok).." r="..tostring(r))
     if ok and r and r~=false and r~="" and r~=0 then
      log("LEVEL "..lv.." OPENED!")
      st.casesOpened=st.casesOpened+1
      quickSell()
     else
      dlog("  "..lv.." failed, 10min CD")
      lvlCooldowns[lv]=os.time()+600
     end
     -- Try claim reward remotes
     if Rem then
      wait(1)
      for _,rn in ipairs({"ClaimLevelReward","ClaimReward","CollectLevelReward","CollectReward","RedeemReward"}) do
       local rm=Rem:FindFirstChild(rn)
       if rm then pcall(function() rm:InvokeServer(lv) end);pcall(function() rm:FireServer(lv) end) end
      end
     end
     -- 10s pause between each level case
     if i<#ready then wait(10) end
    end
    _G.LP_LEVEL_ACTIVE=false
    log("LVL: cycle done, farm resumed")
   end)
  end
 end
end))
-- P1-P4: XP farm / Earn / Farm / Battles (paused while LP_LEVEL_ACTIVE)
coroutine.resume(coroutine.create(function()
 while wait(0.2) do
  if not _G.LP_LEVEL_ACTIVE then
  pcall(function()
   -- P3: XP FARM (open XP cases while bal > min balance)
   if _G.LP_XPFARM then
    local minBal=_G.LP_XP_BUDGET or 500
    local xpCase=_G.LP_XP_CASE
    local xpQty=_G.LP_XP_QTY or 5
    if not xpCase then
     if Cases then for id,d in pairs(Cases) do if type(d)=="table" and d.Price and d.Price>0 and d.Price<=100 then xpCase=id;break end end end
     if xpCase then _G.LP_XP_CASE=xpCase end
    end
    if xpCase then
     local bal=gBal()
     local casePrice=0
     if Cases and Cases[xpCase] and Cases[xpCase].Price then casePrice=Cases[xpCase].Price end
     local costPerOpen=casePrice*xpQty;if costPerOpen<=0 then costPerOpen=xpQty end
     if bal>minBal and bal>=costPerOpen then
      st.xpPhase="SPENDING"
      local bal1=gBal()
      local ok=openCase(xpCase,xpQty)
      wait(0.2);local bal2=gBal();local cost=bal1-bal2
      if cost>0 then st.xpSpent=st.xpSpent+cost end
      if ok then st.xpCases=st.xpCases+xpQty;st.xpW=st.xpW+1 else st.xpL=st.xpL+1 end
      st.casesOpened=st.casesOpened+xpQty
      quickSell()
      return
     end
    end
   end
   -- P3.5: EARN CASES (when XP farm active but no money, or standalone farm)
   if _G.LP_XPFARM or (_G.LP_FARM and not _G.LP_XPFARM) then
    local earnCase=_G.LP_XP_EARN_CASE or GC or "Free"
    if _G.LP_FARM and not _G.LP_XPFARM then earnCase=_G.LP_FARM_CASE or GC or "Free" end
    if _G.LP_XPFARM then st.xpPhase="EARNING" end
    -- Free cases (Group, VIP, Free) use qty=5, paid use qty=1
    local casePrice=0
    if Cases and Cases[earnCase] and Cases[earnCase].Price then casePrice=Cases[earnCase].Price end
    local eq=(casePrice<=0) and 5 or 1
    local ebal1=gBal()
    local ok=openCase(earnCase,eq)
    if not ok then
     -- Retry with qty=1 in case qty=5 is rejected
     if eq>1 then ok=openCase(earnCase,1);eq=1 end
    end
    wait(0.2);quickSell();wait(0.1)
    local ebal2=gBal();local diff=ebal2-ebal1
    if diff>0 and _G.LP_XPFARM then st.xpEarned=st.xpEarned+diff end
    st.casesOpened=st.casesOpened+eq
    if _G.LP_FARM and not _G.LP_XPFARM then st.sessions=st.sessions+1 end
    return
   end
   -- P4: AUTO BATTLE (lowest priority)
   if _G.LP_AUTOBATTLE and cbR and abR then
    local mb=_G.LP_BATTLE_MIN_BAL or 100;local bal=gBal()
    if bal-mb>=10 then
     local cids={};for id in pairs(_G.LP_BATTLE_CASES) do table.insert(cids,tostring(id)) end
     if #cids==0 and Cases then
      local cn={};for id,d in pairs(Cases) do if type(d)=="table" and d.Price and d.Price>0 and d.ForBattles then table.insert(cn,{id=id,price=d.Price}) end end
      table.sort(cn,function(a,b) return a.price<b.price end)
      local lim=math.min(_G.LP_BATTLE_BUDGET or 500,bal-mb)
      for _,c in ipairs(cn) do if c.price<=lim*0.5 then table.insert(cids,tostring(c.id)) end end
     end
     if #cids>0 then
      local bal1=gBal()
      local ok,bid=pcall(function() return cbR:InvokeServer(cids,2,_G.LP_BATTLE_MODE or "CRAZY TERMINAL",false) end)
      if ok and bid then
       wait(0.6);pcall(function() abR:FireServer(tonumber(bid),LP) end)
       st.battlesPlayed=st.battlesPlayed+1;wait(12)
       local bal2=gBal();local diff=bal2-bal1
       if diff>0 then st.battlesWon=st.battlesWon+1;st.battleProfit=st.battleProfit+diff;log("AB W +$"..math.floor(diff))
       else st.battlesLost=st.battlesLost+1;st.battleProfit=st.battleProfit+diff;log("AB L $"..math.floor(diff)) end
      end
     end
    end
   end
  end)
  end -- if not LP_LEVEL_ACTIVE
 end
end))
coroutine.resume(coroutine.create(function()
 while wait(2) do
  if _G.LP_SELL then
   pcall(function()
    local inv=gInv();if not inv then return end
    local kp=_G.LP_KEEP_ABOVE_PRICE or 500;local mx=_G.LP_SELL_MAX or 50
    local batch={}
    for _,i in ipairs(inv:GetChildren()) do
     if #batch>=mx then break end
     if not i:GetAttribute("Locked") then local p=gPrice(i);if p>0 and p<kp then table.insert(batch,i) end end
    end
    if #batch>0 then
     local entries={};for _,item in ipairs(batch) do table.insert(entries,buildSellEntry(item)) end
     local bal1=gBal();pcall(function() slR:InvokeServer(entries) end);wait(0.5);local bal2=gBal()
     if bal2>bal1 then st.earned=st.earned+(bal2-bal1);st.sold=st.sold+#batch;log("Sold "..#batch.." +$"..math.floor(bal2-bal1))
     else for _,item in ipairs(batch) do if not _G.LP_SELL then break end;sellOne(item);wait(0.3) end end
    end
   end);wait(3)
  end
 end
end))
-- EVENTS (independent)
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_EVENT then
   pcall(function()
    local met=WS:FindFirstChild("Meteorites") or WS:FindFirstChild("Events") or WS:FindFirstChild("Meteors")
    if met then for _,m in ipairs(met:GetChildren()) do if not _G.LP_EVENT then break end;pcall(function() local cd=m:FindFirstChild("ClickDetector");if cd then fireclickdetector(cd) end;local pp=m:FindFirstChild("ProximityPrompt");if pp then fireproximityprompt(pp) end end);wait(0.2) end end
   end);wait(5)
  end
 end
end))
-- EXCHANGE/GIFTS (independent)
coroutine.resume(coroutine.create(function()
 while wait(1) do if _G.LP_EXCHANGE and exR then pcall(function() exR:FireServer() end);wait(10) end end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_GIFTS then
   pcall(function()
    -- Try UpdateRewards with each reward index (1-9 for the 9 timed gifts)
    if urR then
     for i=1,9 do
      pcall(function() urR:InvokeServer(i) end)
      wait(0.3)
     end
     -- Also try with no args
     pcall(function() urR:InvokeServer() end)
    end
    -- Try all known reward remote names with indices
    if Rem then
     for _,rn in ipairs({"CollectReward","ClaimGift","ClaimDailyReward","DailyReward","FreeReward","ClaimReward","Reward","Gifts","Gift","ClaimGifts","CollectGift","CollectGifts","RedeemGift"}) do
      local r=Rem:FindFirstChild(rn)
      if r then
       for i=1,9 do pcall(function() r:FireServer(i) end);pcall(function() r:InvokeServer(i) end) end
       pcall(function() r:FireServer() end);pcall(function() r:InvokeServer() end)
      end
     end
    end
    dlog("GIFTS: claimed cycle")
   end);wait(30)
  end
 end
end))
-- UPGRADER (independent)
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_UPGRADER and upR then
   pcall(function()
    local maxM=_G.LP_UPGRADER_MAX_MONEY or 5000
    if st.upgSpent>=maxM then wait(5);return end
    local inv=gInv();if not inv then return end
    local best=nil;local bp=math.huge
    local mn2=_G.LP_UPGRADER_MIN_PRICE or 0;local mx=_G.LP_UPGRADER_MAX_PRICE or 50
    for _,i in ipairs(inv:GetChildren()) do
     if not i:GetAttribute("Locked") then
      local p=gPrice(i);if p>=mn2 and p<=mx and p>0 and p<bp then bp=p;best=i end
     end
    end
    if best then
     if st.upgSpent+bp>maxM then wait(3);return end
     local m=_G.LP_UPGRADER_MULT or 2;local bal1=gBal()
     st.upgAttempts=st.upgAttempts+1;st.upgSpent=st.upgSpent+bp
     local ok,r=doUpgrade(best,m)
     dlog("AutoUpg: ok="..tostring(ok).." r="..tostring(r))
     wait(1.5);local bal2=gBal();local diff=bal2-bal1
     if diff>0 then st.upgWins=st.upgWins+1;st.upgProfit=st.upgProfit+diff;log("Upg W +$"..math.floor(diff))
     else st.upgLosses=st.upgLosses+1;st.upgProfit=st.upgProfit+diff;log("Upg L") end
    end
   end);wait(2)
  end
 end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do if _G.LP_ANTIAFK then pcall(function() local vu=game:GetService("VirtualUser");vu:CaptureController();vu:ClickButton2(Vector2.new()) end);wait(30) end end
end))
-- Reset level retries every 2 min (in case player leveled up)
coroutine.resume(coroutine.create(function()
 while wait(120) do lvlRetries={};lvlIdx=1;dlog("LvlRetries reset") end
end))
coroutine.resume(coroutine.create(function()
 while wait(5) do if dbgBox then pcall(function() dbgBox.Text=table.concat(DL,"\n") end) end end
end))
log("Ready!")
