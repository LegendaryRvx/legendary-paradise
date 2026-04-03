print("[LP] v2.4 loading...")
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local WS=game:GetService("Workspace")
local LP=Players.LocalPlayer
local DL={}
local function dlog(m) local s="["..string.format("%.1f",os.clock()).."] "..tostring(m);table.insert(DL,s);print("[LP] "..tostring(m)) end
dlog("=== LP v2.4 ===")
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
local ocR,slR,exR,cbR,abR,upR,urR
if Rem then
 ocR=Rem:FindFirstChild("OpenCase")
 slR=Rem:FindFirstChild("Sell")
 exR=Rem:FindFirstChild("ExchangeEvent")
 cbR=Rem:FindFirstChild("CreateBattle")
 abR=Rem:FindFirstChild("AddBot")
 upR=Rem:FindFirstChild("Upgrade")
 urR=Rem:FindFirstChild("UpdateRewards")
 dlog("Remotes: OC="..(ocR and ocR.ClassName or "X").." Sell="..(slR and slR.ClassName or "X").." Up="..(upR and upR.ClassName or "X"))
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
local spyLog={}
local _origInvoke,_origFire
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
    for i2,a in ipairs(args) do
     if type(a)=="table" then
      local ts={}
      for k,v in pairs(a) do table.insert(ts,tostring(k).."="..tostring(v)) end
      table.insert(aStr,"t{"..table.concat(ts,",").."}")
     else table.insert(aStr,type(a)..":"..tostring(a)) end
    end
    local entry="[SPY] "..self.Name.."."..method.."("..table.concat(aStr,", ")..")"
    table.insert(spyLog,entry);dlog(entry)
   end
   return oldNC(self,...)
  end)
  setreadonly(mt,true)
  dlog("SPY: namecall hooked")
 else dlog("SPY: no getrawmetatable") end
end)
pcall(function()
 if hookfunction and ocR then
  _origInvoke=ocR.InvokeServer
 end
end)
dlog("--- Cases Module Dump (3) ---")
pcall(function()
 if Cases then
  local n=0
  for id,d in pairs(Cases) do
   if n>=3 then break end
   if type(d)=="table" then
    n=n+1
    local fields={}
    for k,v in pairs(d) do
     if type(v)~="table" then table.insert(fields,tostring(k).."="..tostring(v))
     else table.insert(fields,tostring(k).."={...}") end
    end
    dlog("Case["..tostring(id).."]: "..table.concat(fields,", "))
   else dlog("Case["..tostring(id).."]: "..type(d).."="..tostring(d)) end
  end
 end
end)
dlog("--- Inv ---")
pcall(function()
 local inv=gInv()
 if inv then
  local ch=inv:GetChildren();dlog("Inv: "..#ch.." items")
  for i=1,math.min(5,#ch) do
   local it=ch[i];dlog("  "..it.ClassName..": "..it.Name.." UUID="..tostring(getUUID(it)).." $"..gPrice(it).." W="..(getWear(it) or "?").." ST="..tostring(getST(it)))
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
_G.LP_ANTIAFK=false;_G.LP_AUTOBATTLE=false
_G.LP_FARM_CASE=GC or "Free"
_G.LP_SELL_MAX=50;_G.LP_KEEP_ABOVE_PRICE=500
_G.LP_UPGRADER_MIN_PRICE=0;_G.LP_UPGRADER_MAX_PRICE=50;_G.LP_UPGRADER_MULT=2;_G.LP_UPGRADER_MAX_MONEY=5000
_G.LP_BATTLE_BUDGET=500;_G.LP_BATTLE_MIN_BAL=100
_G.LP_BATTLE_MODE="CRAZY TERMINAL";_G.LP_BATTLE_CASES={}
local st={sessions=0,casesOpened=0,earned=0,sold=0,upgAttempts=0,upgWins=0,upgLosses=0,upgProfit=0,upgSpent=0,battlesPlayed=0,battlesWon=0,battlesLost=0,battleProfit=0}
local function tryOpenCase(cid)
 if not ocR then dlog("OC: nil");return false end
 dlog("OC: cid="..tostring(cid).." type="..type(cid))
 local cData=nil
 if Cases and Cases[cid] then cData=Cases[cid] end
 local invBefore=0
 pcall(function() local inv=gInv();if inv then invBefore=#inv:GetChildren() end end)
 local bal1=gBal()
 local patterns={}
 table.insert(patterns,{"raw",{cid}})
 if type(cid)=="string" then
  table.insert(patterns,{"num",{tonumber(cid)}})
 end
 if type(cid)=="number" then
  table.insert(patterns,{"str",{tostring(cid)}})
 end
 if cData then
  if cData.Name then table.insert(patterns,{"Name",{cData.Name}}) end
  if cData.Id then table.insert(patterns,{"Id",{cData.Id}}) end
  if cData.CaseId then table.insert(patterns,{"CaseId",{cData.CaseId}}) end
 end
 table.insert(patterns,{"{Case=}",{{Case=cid}}})
 table.insert(patterns,{"{CaseId=}",{{CaseId=cid}}})
 if cData and cData.Name then
  table.insert(patterns,{"{Case=Name}",{{Case=cData.Name}}})
 end
 table.insert(patterns,{"1,cid",{1,cid}})
 for _,p in ipairs(patterns) do
  local label=p[1];local args=p[2]
  local argStr={}
  for _,a in ipairs(args) do
   if type(a)=="table" then local ts={};for k,v in pairs(a) do table.insert(ts,k.."="..tostring(v)) end;table.insert(argStr,"{"..table.concat(ts,",").."}")
   else table.insert(argStr,type(a)..":"..tostring(a)) end
  end
  local ok,r=pcall(function() return ocR:InvokeServer(unpack(args)) end)
  dlog("  OC["..label.."]("..table.concat(argStr,",").."): ok="..tostring(ok).." r="..tostring(r))
  wait(0.4)
  local bal2=gBal()
  if bal2~=bal1 then dlog("  >> OC["..label.."] WORKED bal "..tostring(bal1).."->"..tostring(bal2));return true,label end
  local invAfter=0
  pcall(function() local inv=gInv();if inv then invAfter=#inv:GetChildren() end end)
  if invAfter>invBefore then dlog("  >> OC["..label.."] WORKED inv "..invBefore.."->"..invAfter);return true,label end
 end
 return false,"no change"
end
local function trySellItem(item)
 if not slR then dlog("Sell: nil");return false end
 local n=item.Name
 local w=getWear(item)
 local st2=getST(item)
 local uuid=getUUID(item)
 dlog("Sell: "..n.." w="..(w or "nil").." st="..tostring(st2).." uuid="..(uuid or "nil"))
 local bal1=gBal()
 local invBefore=0
 pcall(function() local inv=gInv();if inv then invBefore=#inv:GetChildren() end end)
 local patterns={}
 if uuid then
  table.insert(patterns,{"uuid",{uuid}})
  table.insert(patterns,{"{uuid}",{{uuid}}})
  table.insert(patterns,{"{UUID=}",{{UUID=uuid}}})
  table.insert(patterns,{"{UUID=,Name=}",{{UUID=uuid,Name=n}}})
 end
 table.insert(patterns,{"name",{n}})
 table.insert(patterns,{"n,w",{n,w}})
 table.insert(patterns,{"n,w,st",{n,w,st2}})
 table.insert(patterns,{"{N,W,S}",{{Name=n,Wear=w,Stattrak=st2}}})
 table.insert(patterns,{"inst",{item}})
 table.insert(patterns,{"{n}",{{n}}})
 if uuid then
  table.insert(patterns,{"n,uuid",{n,uuid}})
  table.insert(patterns,{"uuid,1",{uuid,1}})
 end
 for _,p in ipairs(patterns) do
  local label=p[1];local args=p[2]
  local argStr={}
  for _,a in ipairs(args) do
   if type(a)=="table" then local ts={};for k,v in pairs(a) do table.insert(ts,tostring(k).."="..tostring(v)) end;table.insert(argStr,"{"..table.concat(ts,",").."}")
   elseif type(a)=="userdata" then table.insert(argStr,"inst:"..tostring(a))
   else table.insert(argStr,type(a)..":"..tostring(a)) end
  end
  local ok,r=pcall(function() return slR:InvokeServer(unpack(args)) end)
  dlog("  S["..label.."]("..table.concat(argStr,",").."): ok="..tostring(ok).." r="..tostring(r))
  wait(0.4)
  local bal2=gBal()
  if bal2>bal1 then dlog("  >> S["..label.."] WORKED +"..tostring(bal2-bal1));return true,label end
  local invAfter=0
  pcall(function() local inv=gInv();if inv then invAfter=#inv:GetChildren() end end)
  if invAfter<invBefore then dlog("  >> S["..label.."] WORKED inv "..invBefore.."->"..invAfter);return true,label end
 end
 dlog("  Sell FAILED all")
 return false
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
local tl=Instance.new("TextLabel");tl.Size=UDim2.new(1,-70,1,0);tl.Position=UDim2.new(0,10,0,0);tl.BackgroundTransparency=1;tl.Text="LP v2.4 DEBUG";tl.TextColor3=C.ac;tl.TextSize=12;tl.Font=Enum.Font.GothamBold;tl.TextXAlignment=Enum.TextXAlignment.Left;tl.Parent=topb
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
 mSec(pg,"LEGENDARY PARADISE v2.4",1)
 mLbl(pg,"UUID-based + Remote Spy",2)
 mSec(pg,"PLAYER",3);local il=mLbl(pg,"...",4)
 mSec(pg,"STATS",7);local sl=mLbl(pg,"...",8)
 mSec(pg,"LIVE LOG",9)
 local lb=Instance.new("Frame");lb.Size=UDim2.new(1,0,0,120);lb.BackgroundColor3=C.lb;lb.BorderSizePixel=0;lb.LayoutOrder=10;lb.Parent=pg
 pcall(function() Instance.new("UICorner",lb).CornerRadius=UDim.new(0,6) end)
 logLbl=Instance.new("TextLabel");logLbl.Size=UDim2.new(1,-6,1,-4);logLbl.Position=UDim2.new(0,3,0,2);logLbl.BackgroundTransparency=1;logLbl.Text="...";logLbl.TextColor3=Color3.fromRGB(160,220,160);logLbl.TextSize=8;logLbl.Font=Enum.Font.Code;logLbl.TextXAlignment=Enum.TextXAlignment.Left;logLbl.TextYAlignment=Enum.TextYAlignment.Top;logLbl.TextWrapped=true;logLbl.Parent=lb
 coroutine.resume(coroutine.create(function() while wait(2) do pcall(function()
  il.Text="Lv:"..tostring(gLvl()).." $"..tostring(math.floor(gBal()))
  sl.Text="S:"..st.sessions.." C:"..st.casesOpened.." Sold:"..st.sold.." $"..math.floor(st.earned)
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
  local fb=Instance.new("TextButton");fb.Size=UDim2.new(1,-4,0,16);fb.BackgroundColor3=sel and C.ac or C.cd;fb.Text="["..tostring(e.id).."] "..e.name..(e.price>0 and(" $"..e.price) or " FREE");fb.TextColor3=sel and Color3.fromRGB(0,0,0) or C.tx;fb.TextSize=8;fb.Font=Enum.Font.Gotham;fb.TextXAlignment=Enum.TextXAlignment.Left;fb.BorderSizePixel=0;fb.LayoutOrder=idx;fb.Parent=fcs
  pcall(function() Instance.new("UICorner",fb).CornerRadius=UDim.new(0,4) end)
  fcBs[e.id]=fb
  fb.MouseButton1Click:Connect(function() _G.LP_FARM_CASE=e.id;fcl.Text="Case: "..e.name.." (id="..tostring(e.id)..")";for k,v in pairs(fcBs) do if k==e.id then v.BackgroundColor3=C.ac;v.TextColor3=Color3.fromRGB(0,0,0) else v.BackgroundColor3=C.cd;v.TextColor3=C.tx end end end)
 end
 mSec(pg,"AUTO SELL",10);mTog(pg,"Auto Sell","LP_SELL",C.or2,11)
 mInput(pg,"Keep above $",500,"LP_KEEP_ABOVE_PRICE",12)
 mInput(pg,"Max sell/cy",50,"LP_SELL_MAX",13)
 mSec(pg,"AUTO LEVEL",15);mTog(pg,"Auto Level","LP_LEVEL",C.gn,16)
 mSec(pg,"EXTRAS",20);mTog(pg,"Events","LP_EVENT",C.pu,21);mTog(pg,"Exchange","LP_EXCHANGE",C.gn,22);mTog(pg,"Gifts","LP_GIFTS",C.gn,23)
 mBtn(pg,"ALL ON",C.gn,function() _G.LP_FARM=true;_G.LP_SELL=true;_G.LP_EVENT=true;_G.LP_LEVEL=true;_G.LP_EXCHANGE=true;_G.LP_GIFTS=true;log("All ON");swT("Auto") end,28)
 mBtn(pg,"ALL OFF",C.rd,function() _G.LP_FARM=false;_G.LP_SELL=false;_G.LP_EVENT=false;_G.LP_LEVEL=false;_G.LP_EXCHANGE=false;_G.LP_GIFTS=false;log("All OFF");swT("Auto") end,29)
end)
pcall(function()
 local pg=tP["Battle"]
 local acn2={}
 if Cases then for id,d in pairs(Cases) do if type(d)=="table" and d.Name then table.insert(acn2,{id=id,name=d.Name,price=d.Price or 0}) end end;table.sort(acn2,function(a,b) return a.price<b.price end) end
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
  local cb=Instance.new("TextButton");cb.Size=UDim2.new(1,-4,0,18);cb.BackgroundColor3=C.cd;cb.Text="["..tostring(e.id).."] "..e.name..(e.price>0 and(" $"..e.price) or " FREE");cb.TextColor3=C.tx;cb.TextSize=8;cb.Font=Enum.Font.Gotham;cb.TextXAlignment=Enum.TextXAlignment.Left;cb.BorderSizePixel=0;cb.LayoutOrder=idx;cb.Parent=csc
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
 mLbl(pg,"Upgrade = RemoteEvent (FireServer)",3)
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
 mSec(pg,"CLIENT",1)
 mBtn(pg,"Money $999k",C.bl,function() pcall(function() local pd=LP:FindFirstChild("PlayerData");local c=pd and pd:FindFirstChild("Currencies");local b=c and c:FindFirstChild("Balance");if b then b.Value=999999;log("$999k") end end) end,2)
 mBtn(pg,"Tickets 9999",C.pu,function() pcall(function() local pd=LP:FindFirstChild("PlayerData");local c=pd and pd:FindFirstChild("Currencies");local t=c and c:FindFirstChild("Tickets");if t then t.Value=9999;log("Tix") end end) end,3)
 mSec(pg,"DUPE",5)
 mBtn(pg,"Dupe x1",C.or2,function() local inv=gInv();if not inv then log("No inv");return end;local n=0;for _,i in ipairs(inv:GetChildren()) do if not i:GetAttribute("LPDup") then local cl=i:Clone();cl:SetAttribute("LPDup",true);cl.Parent=inv;n=n+1 end end;log("Duped "..n) end,6)
 mBtn(pg,"Remove Dupes",C.rd,function() local inv=gInv();if not inv then return end;local n=0;for _,i in ipairs(inv:GetChildren()) do if i:GetAttribute("LPDup") then i:Destroy();n=n+1 end end;log("Rm "..n) end,7)
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
 mSec(pg,"STEP 1: SPY on real game",5)
 mLbl(pg,"Open a case / sell item MANUALLY then REFRESH",6)
 mBtn(pg,"Show SPY log",C.pu,function()
  dlog("=== SPY LOG ("..#spyLog..") ===")
  for _,e in ipairs(spyLog) do dlog(e) end
  dlog("=== END SPY ===")
  dbgBox.Text=table.concat(DL,"\n")
 end,7)
 mSec(pg,"STEP 2: Test patterns",8)
 mBtn(pg,"TEST: Open Free",C.gn,function()
  dlog("=== TEST FREE ===")
  local ok,ret=tryOpenCase("Free")
  dlog("Result: "..tostring(ok).." "..tostring(ret))
  dlog("=== END ===");dbgBox.Text=table.concat(DL,"\n")
 end,9)
 mBtn(pg,"TEST: Open case #1 (numeric)",C.gn,function()
  dlog("=== TEST #1 ===")
  local ok,ret=tryOpenCase(1)
  dlog("Result: "..tostring(ok).." "..tostring(ret))
  dlog("=== END ===");dbgBox.Text=table.concat(DL,"\n")
 end,10)
 mBtn(pg,"TEST: Sell cheapest (UUID)",C.or2,function()
  dlog("=== TEST SELL ===")
  local inv=gInv();if not inv then dlog("No inv");dbgBox.Text=table.concat(DL,"\n");return end
  local best=nil;local bp=math.huge
  for _,it in ipairs(inv:GetChildren()) do
   if not it:GetAttribute("Locked") then
    local p=gPrice(it);if p>0 and p<bp then bp=p;best=it end
   end
  end
  if best then dlog("Target: "..best.Name.." $"..bp.." uuid="..tostring(getUUID(best)));trySellItem(best)
  else dlog("No unlocked sellable item") end
  dlog("=== END ===");dbgBox.Text=table.concat(DL,"\n")
 end,11)
 mBtn(pg,"TEST: Upgrade cheapest",C.pu,function()
  dlog("=== TEST UPGRADE ===")
  if not upR then dlog("upR nil");dbgBox.Text=table.concat(DL,"\n");return end
  local inv=gInv();if not inv then dlog("No inv");dbgBox.Text=table.concat(DL,"\n");return end
  local best=nil;local bp=math.huge
  for _,it in ipairs(inv:GetChildren()) do
   if not it:GetAttribute("Locked") then
    local p=gPrice(it);if p>0 and p<bp then bp=p;best=it end
   end
  end
  if not best then dlog("No item");dbgBox.Text=table.concat(DL,"\n");return end
  local uuid=getUUID(best)
  dlog("Upgrading: "..best.Name.." $"..bp.." uuid="..(uuid or "nil").." x2")
  local bal1=gBal()
  local invB=0;pcall(function() invB=#gInv():GetChildren() end)
  local tryPatterns={
   {"inst,2",function() upR:FireServer(best,2) end},
   {"name,2",function() upR:FireServer(best.Name,2) end},
   {"uuid,2",function() if uuid then upR:FireServer(uuid,2) end end},
   {"n,w,2",function() upR:FireServer(best.Name,getWear(best),2) end},
   {"{tbl},2",function() upR:FireServer({Name=best.Name,Wear=getWear(best),UUID=uuid},2) end},
   {"uuid,mult",function() if uuid then upR:FireServer(uuid,"2x") end end},
  }
  for _,tp in ipairs(tryPatterns) do
   local ok,r=pcall(tp[2])
   dlog("  Up["..tp[1].."]: ok="..tostring(ok).." r="..tostring(r))
   wait(1)
  end
  local bal2=gBal()
  local invA=0;pcall(function() invA=#gInv():GetChildren() end)
  dlog("Bal: "..tostring(bal1).."->"..tostring(bal2).." Inv:"..invB.."->"..invA)
  dlog("=== END ===");dbgBox.Text=table.concat(DL,"\n")
 end,12)
 mSec(pg,"DUMPS",13)
 mBtn(pg,"DUMP Cases Module (5)",C.or2,function()
  dlog("=== CASES DUMP ===")
  if not Cases then dlog("No Cases module");dbgBox.Text=table.concat(DL,"\n");return end
  local n=0
  for id,d in pairs(Cases) do
   if n>=5 then break end
   if type(d)=="table" then
    n=n+1;dlog("Case KEY="..tostring(id).." type(key)="..type(id))
    for k,v in pairs(d) do
     if type(v)=="table" then
      local sub={};local c2=0
      for sk,sv in pairs(v) do c2=c2+1;if c2<=3 then table.insert(sub,tostring(sk).."="..tostring(sv)) end end
      dlog("  "..tostring(k).."={"..(table.concat(sub,","))..(c2>3 and ",..." or "").."}")
     else dlog("  "..tostring(k).."="..tostring(v)) end
    end
   end
  end
  dlog("=== END ===");dbgBox.Text=table.concat(DL,"\n")
 end,14)
 mBtn(pg,"DUMP Inventory Full",C.or2,function()
  dlog("=== INV DUMP ===")
  local inv=gInv();if not inv then dlog("No inv");dbgBox.Text=table.concat(DL,"\n");return end
  for _,i in ipairs(inv:GetChildren()) do
   dlog(i.ClassName..": "..i.Name.." Locked="..tostring(i:GetAttribute("Locked") or false).." UUID="..tostring(getUUID(i)))
   local attrs={};pcall(function() for k,v in pairs(i:GetAttributes()) do table.insert(attrs,k.."="..tostring(v)) end end)
   if #attrs>0 then dlog("  "..table.concat(attrs,", ")) end
  end
  dlog("=== END ===");dbgBox.Text=table.concat(DL,"\n")
 end,15)
 mBtn(pg,"DUMP ALL Remotes",C.or2,function()
  dlog("=== REMOTES ===")
  if Rem then for _,r in ipairs(Rem:GetChildren()) do dlog("  "..r.ClassName..": "..r.Name) end end
  dlog("=== END ===");dbgBox.Text=table.concat(DL,"\n")
 end,16)
 mBtn(pg,"CLEAR",C.rd,function() DL={};spyLog={};dlog("Cleared");dbgBox.Text="" end,17)
end)
pcall(function()
 local pg=tP["Config"]
 mSec(pg,"GENERAL",1);mTog(pg,"Anti-AFK","LP_ANTIAFK",C.gn,2)
 mSec(pg,"INFO",4);mLbl(pg,"LP v2.4 DEBUG - LegendaryRvx",5)
 mBtn(pg,"Destroy GUI",C.rd,function() sg:Destroy() end,7)
end)
swT("Dash")
log("v2.4 loaded $"..math.floor(gBal()).." Lv"..tostring(gLvl()))
log("Farm case: "..tostring(_G.LP_FARM_CASE))
log("SPY active: "..tostring(#spyLog>=0))
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_FARM then
   pcall(function()
    local fc=_G.LP_FARM_CASE
    if not fc or fc=="" then log("Select case!");wait(3);return end
    st.sessions=st.sessions+1
    for i=1,5 do
     if not _G.LP_FARM then break end
     local ok,ret=tryOpenCase(fc)
     if ok then st.casesOpened=st.casesOpened+1 end
     wait(0.5)
    end
    log("Farm#"..st.sessions.." c="..st.casesOpened)
   end);wait(2)
  end
 end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_SELL then
   pcall(function()
    local inv=gInv();if not inv then return end
    local kp=_G.LP_KEEP_ABOVE_PRICE or 500;local mx=_G.LP_SELL_MAX or 50;local n=0
    for _,i in ipairs(inv:GetChildren()) do
     if not _G.LP_SELL or n>=mx then break end
     if not i:GetAttribute("Locked") then
      local p=gPrice(i)
      if p>0 and p<kp then
       local ok=trySellItem(i)
       if ok then st.earned=st.earned+p;st.sold=st.sold+1;n=n+1 end
       wait(0.3)
      end
     end
    end
    if n>0 then log("Sold "..n) end
   end);wait(4)
  end
 end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_LEVEL then
   pcall(function()
    if not Cases then return end
    local cc=nil;local cp=math.huge
    for id,d in pairs(Cases) do if type(d)=="table" and d.Price and type(d.Price)=="number" and d.Price>0 and d.Price<cp then cp=d.Price;cc=id end end
    if cc and gBal()>=cp then
     local ok=tryOpenCase(cc);if ok then st.casesOpened=st.casesOpened+1;log("Lvl $"..cp) end
    end
   end);wait(3)
  end
 end
end))
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
coroutine.resume(coroutine.create(function()
 while wait(1) do if _G.LP_EXCHANGE and exR then pcall(function() exR:FireServer() end);wait(10) end end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_GIFTS then
   pcall(function()
    if urR then pcall(function() urR:InvokeServer() end) end
    if Rem then for _,rn in ipairs({"CollectReward","ClaimGift","ClaimDailyReward","DailyReward","FreeReward","PrepareGiftPurchase"}) do local r=Rem:FindFirstChild(rn);if r then pcall(function() r:FireServer() end);pcall(function() r:InvokeServer() end) end end end
   end);wait(15)
  end
 end
end))
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
     local m=_G.LP_UPGRADER_MULT or 2;local uuid=getUUID(best);local bal1=gBal()
     st.upgAttempts=st.upgAttempts+1;st.upgSpent=st.upgSpent+bp
     pcall(function() upR:FireServer(best,m) end)
     pcall(function() upR:FireServer(best.Name,m) end)
     if uuid then pcall(function() upR:FireServer(uuid,m) end) end
     pcall(function() upR:FireServer(best.Name,getWear(best),m) end)
     wait(1.5)
     local bal2=gBal();local diff=bal2-bal1
     if diff>0 then st.upgWins=st.upgWins+1;st.upgProfit=st.upgProfit+diff;log("Upg W +$"..math.floor(diff))
     else st.upgLosses=st.upgLosses+1;st.upgProfit=st.upgProfit+diff;log("Upg L") end
    end
   end);wait(2)
  end
 end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_AUTOBATTLE and cbR and abR then
   pcall(function()
    local mb=_G.LP_BATTLE_MIN_BAL or 100;local bal=gBal()
    if bal-mb<10 then wait(5);return end
    local cids={};for id in pairs(_G.LP_BATTLE_CASES) do table.insert(cids,tostring(id)) end
    if #cids==0 then
     if Cases then
      local cn={};for id,d in pairs(Cases) do if type(d)=="table" and d.Price and d.Price>0 then table.insert(cn,{id=id,price=d.Price}) end end
      table.sort(cn,function(a,b) return a.price<b.price end)
      local lim=math.min(_G.LP_BATTLE_BUDGET or 500,bal-mb)
      for _,c in ipairs(cn) do if c.price<=lim*0.5 then table.insert(cids,tostring(c.id)) end end
     end
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
   end);wait(4)
  end
 end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do if _G.LP_ANTIAFK then pcall(function() local vu=game:GetService("VirtualUser");vu:CaptureController();vu:ClickButton2(Vector2.new()) end);wait(30) end end
end))
coroutine.resume(coroutine.create(function()
 while wait(5) do if dbgBox then pcall(function() dbgBox.Text=table.concat(DL,"\n") end) end end
end))
log("Ready! Use Debug tab -> SPY first")
