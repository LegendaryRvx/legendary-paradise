print("[LP] * LEGENDARY PARADISE * loading...")
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local WS=game:GetService("Workspace")
local LP=Players.LocalPlayer
local Items,Cases,LevelCalc,Rarities,UpgMod
pcall(function()
 local M=RS:FindFirstChild("Modules") or RS:WaitForChild("Modules",3)
 if M then
  pcall(function() Items=require(M:WaitForChild("Items",3)) end)
  pcall(function() Cases=require(M:WaitForChild("Cases",3)) end)
  pcall(function() LevelCalc=require(M:WaitForChild("LevelCalculator",3)) end)
  pcall(function() Rarities=require(M:WaitForChild("Rarities",3)) end)
  pcall(function() UpgMod=require(M:WaitForChild("Upgrader",3)) end)
 end
end)
local Rem=RS:FindFirstChild("Remotes") or RS:WaitForChild("Remotes",5)
local ocR,slR,exR,cbR,abR,upR,urR
if Rem then
 ocR=Rem:FindFirstChild("OpenCase") or Rem:WaitForChild("OpenCase",3)
 slR=Rem:FindFirstChild("Sell") or Rem:WaitForChild("Sell",3)
 exR=Rem:FindFirstChild("ExchangeEvent")
 cbR=Rem:FindFirstChild("CreateBattle")
 abR=Rem:FindFirstChild("AddBot")
 upR=Rem:FindFirstChild("Upgrade")
 urR=Rem:FindFirstChild("UpdateRewards")
end
local function gInv()
 local pd=LP:FindFirstChild("PlayerData")
 if not pd then return nil end
 return pd:FindFirstChild("Inventory") or pd:FindFirstChild("Skins") or pd:FindFirstChild("Items")
end
local function gBal()
 local pd=LP:FindFirstChild("PlayerData")
 local c=pd and pd:FindFirstChild("Currencies")
 local b=c and c:FindFirstChild("Balance")
 return b and b.Value or 0
end
local function gLvl()
 if not LevelCalc or not LevelCalc.CalculateLevel then return 0 end
 local pd=LP:FindFirstChild("PlayerData")
 local e=pd and pd:FindFirstChild("Currencies") and pd.Currencies:FindFirstChild("Experience")
 if not e then return 0 end
 local d=LevelCalc.CalculateLevel(e.Value)
 return d and d.Level or 0
end
local function gPrice(item)
 if not Items then return 0 end
 local d=Items[item.Name]
 if not d or not d.Wears then return 0 end
 local w=item:GetAttribute("Wear")
 local stt=item:GetAttribute("Stattrak")==true
 if not w or not d.Wears[w] then for wn in pairs(d.Wears) do w=wn;break end end
 if not w or not d.Wears[w] then return 0 end
 local wd=d.Wears[w]
 if stt then return wd.StatTrak or wd.Normal or 0 else return wd.Normal or wd.StatTrak or 0 end
end
local GC=nil
if Cases then
 for id,d in pairs(Cases) do
  if type(d)=="table" and d.Name then
   if d.GroupOnly==true or string.lower(tostring(d.Name)):find("group") then GC=id;break end
  end
 end
end
_G.LP_FARM=false;_G.LP_SELL=false;_G.LP_EVENT=false;_G.LP_LEVEL=false
_G.LP_QUESTS=false;_G.LP_EXCHANGE=false;_G.LP_GIFTS=false;_G.LP_UPGRADER=false
_G.LP_ANTIAFK=false;_G.LP_AUTOBATTLE=false
_G.LP_CASES_PER_ROUND=5;_G.LP_ROUNDS_PER_SESSION=5;_G.LP_KEEP_ABOVE_PRICE=900
_G.LP_UPGRADER_MIN_PRICE=0;_G.LP_UPGRADER_MAX_PRICE=50;_G.LP_UPGRADER_MULT=2
_G.LP_BATTLE_BUDGET=500;_G.LP_BATTLE_MIN_BAL=100;_G.LP_BATTLE_RISK="Medium"
_G.LP_BATTLE_MODE="CRAZY TERMINAL";_G.LP_BATTLE_CASE=""
local st={sessions=0,casesOpened=0,earned=0,upgAttempts=0,upgWins=0,upgLosses=0,upgProfit=0,battlesPlayed=0,battlesWon=0,battlesLost=0,battleProfit=0}
pcall(function()
 if game:GetService("CoreGui"):FindFirstChild("LegendaryParadiseUI") then game:GetService("CoreGui").LegendaryParadiseUI:Destroy() end
 if LP.PlayerGui:FindFirstChild("LegendaryParadiseUI") then LP.PlayerGui.LegendaryParadiseUI:Destroy() end
end)
local sg=Instance.new("ScreenGui");sg.Name="LegendaryParadiseUI"
pcall(function() sg.ResetOnSpawn=false end)
pcall(function() sg.Parent=game:GetService("CoreGui") end)
if not sg.Parent then pcall(function() sg.Parent=LP.PlayerGui end) end
local C={bg=Color3.fromRGB(12,12,16),sb=Color3.fromRGB(18,18,22),tb=Color3.fromRGB(20,20,26),cd=Color3.fromRGB(22,22,28),ac=Color3.fromRGB(255,185,0),ton=Color3.fromRGB(0,170,90),tof=Color3.fromRGB(55,55,62),tx=Color3.fromRGB(210,210,215),td=Color3.fromRGB(120,120,130),tw=Color3.fromRGB(255,255,255),rd=Color3.fromRGB(220,50,50),bl=Color3.fromRGB(0,140,230),pu=Color3.fromRGB(160,0,220),or2=Color3.fromRGB(230,120,0),gn=Color3.fromRGB(0,180,80),lb=Color3.fromRGB(8,8,10)}
local mn=Instance.new("Frame");mn.Name="Main";mn.Size=UDim2.new(0,480,0,380);mn.Position=UDim2.new(0.5,-240,0.5,-190);mn.BackgroundColor3=C.bg;mn.BorderSizePixel=0
pcall(function() mn.Active=true end);pcall(function() mn.Draggable=true end)
mn.Parent=sg;pcall(function() Instance.new("UICorner",mn).CornerRadius=UDim.new(0,10) end)
local topb=Instance.new("Frame");topb.Size=UDim2.new(1,0,0,32);topb.BackgroundColor3=C.tb;topb.BorderSizePixel=0;topb.Parent=mn
pcall(function() Instance.new("UICorner",topb).CornerRadius=UDim.new(0,10) end)
local tf=Instance.new("Frame");tf.Size=UDim2.new(1,0,0,10);tf.Position=UDim2.new(0,0,1,-10);tf.BackgroundColor3=C.tb;tf.BorderSizePixel=0;tf.Parent=topb
local tl=Instance.new("TextLabel");tl.Size=UDim2.new(1,-70,1,0);tl.Position=UDim2.new(0,10,0,0);tl.BackgroundTransparency=1;tl.Text="* LEGENDARY PARADISE *";tl.TextColor3=C.ac;tl.TextSize=14;tl.Font=Enum.Font.GothamBold;tl.TextXAlignment=Enum.TextXAlignment.Left;tl.Parent=topb
local xb=Instance.new("TextButton");xb.Size=UDim2.new(0,26,0,22);xb.Position=UDim2.new(1,-32,0,5);xb.BackgroundColor3=C.rd;xb.Text="X";xb.TextColor3=C.tw;xb.TextSize=12;xb.Font=Enum.Font.GothamBold;xb.BorderSizePixel=0;xb.Parent=topb
pcall(function() Instance.new("UICorner",xb).CornerRadius=UDim.new(0,5) end)
xb.MouseButton1Click:Connect(function() sg:Destroy() end)
local mmb=Instance.new("TextButton");mmb.Size=UDim2.new(0,26,0,22);mmb.Position=UDim2.new(1,-62,0,5);mmb.BackgroundColor3=Color3.fromRGB(55,55,60);mmb.Text="_";mmb.TextColor3=C.tx;mmb.TextSize=12;mmb.Font=Enum.Font.GothamBold;mmb.BorderSizePixel=0;mmb.Parent=topb
pcall(function() Instance.new("UICorner",mmb).CornerRadius=UDim.new(0,5) end)
local bf=Instance.new("Frame");bf.Size=UDim2.new(1,0,1,-32);bf.Position=UDim2.new(0,0,0,32);bf.BackgroundTransparency=1;bf.Parent=mn
mmb.MouseButton1Click:Connect(function() bf.Visible=not bf.Visible;mn.Size=bf.Visible and UDim2.new(0,480,0,380) or UDim2.new(0,480,0,32) end)
local sbar=Instance.new("Frame");sbar.Size=UDim2.new(0,105,1,0);sbar.BackgroundColor3=C.sb;sbar.BorderSizePixel=0;sbar.Parent=bf
pcall(function() Instance.new("UICorner",sbar).CornerRadius=UDim.new(0,8) end)
local ca=Instance.new("Frame");ca.Size=UDim2.new(1,-110,1,-4);ca.Position=UDim2.new(0,108,0,2);ca.BackgroundTransparency=1;ca.Parent=bf
local tP,tB,aT={},{},nil
local tD={{"Dashboard"},{"Automation"},{"Battles"},{"Upgrader"},{"Exploits"},{"Settings"}}
local function swT(n)
 aT=n
 for k,p in pairs(tP) do p.Visible=(k==n) end
 for k,b in pairs(tB) do
  if k==n then b.BackgroundColor3=C.ac;b.TextColor3=Color3.fromRGB(0,0,0) else b.BackgroundColor3=Color3.fromRGB(30,30,36);b.TextColor3=C.tx end
 end
end
for i,d in ipairs(tD) do
 local b=Instance.new("TextButton");b.Size=UDim2.new(1,-12,0,28);b.Position=UDim2.new(0,6,0,6+(i-1)*33);b.BackgroundColor3=Color3.fromRGB(30,30,36);b.Text=d[1];b.TextColor3=C.tx;b.TextSize=11;b.Font=Enum.Font.GothamBold;b.BorderSizePixel=0;b.Parent=sbar
 pcall(function() Instance.new("UICorner",b).CornerRadius=UDim.new(0,6) end)
 tB[d[1]]=b;b.MouseButton1Click:Connect(function() swT(d[1]) end)
end
for _,d in ipairs(tD) do
 local s=Instance.new("ScrollingFrame");s.Size=UDim2.new(1,0,1,0);s.BackgroundTransparency=1;s.BorderSizePixel=0;s.ScrollBarThickness=4;s.ScrollBarImageColor3=C.ac;s.CanvasSize=UDim2.new(0,0,0,2000);s.Visible=false;s.Parent=ca
 local l=Instance.new("UIListLayout");l.SortOrder=Enum.SortOrder.LayoutOrder;l.Padding=UDim.new(0,5);l.Parent=s
 pcall(function() l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() s.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+10) end) end)
 local p=Instance.new("UIPadding");p.PaddingLeft=UDim.new(0,4);p.PaddingRight=UDim.new(0,4);p.PaddingTop=UDim.new(0,4);p.Parent=s
 tP[d[1]]=s
end
local function mSec(p,t,o) local l=Instance.new("TextLabel");l.Size=UDim2.new(1,0,0,20);l.BackgroundTransparency=1;l.Text="- "..t.." -";l.TextColor3=C.ac;l.TextSize=11;l.Font=Enum.Font.GothamBold;l.LayoutOrder=o or 0;l.Parent=p;return l end
local function mLbl(p,t,o) local l=Instance.new("TextLabel");l.Size=UDim2.new(1,0,0,18);l.BackgroundTransparency=1;l.Text=t;l.TextColor3=C.tx;l.TextSize=11;l.Font=Enum.Font.Gotham;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextWrapped=true;l.LayoutOrder=o or 0;l.Parent=p;return l end
local function mTog(p,lt,fl,co,o)
 local r=Instance.new("Frame");r.Size=UDim2.new(1,0,0,30);r.BackgroundColor3=C.cd;r.BorderSizePixel=0;r.LayoutOrder=o or 0;r.Parent=p
 pcall(function() Instance.new("UICorner",r).CornerRadius=UDim.new(0,6) end)
 local l=Instance.new("TextLabel");l.Size=UDim2.new(1,-58,1,0);l.Position=UDim2.new(0,8,0,0);l.BackgroundTransparency=1;l.Text=lt;l.TextColor3=C.tx;l.TextSize=11;l.Font=Enum.Font.Gotham;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextWrapped=true;l.Parent=r
 local b=Instance.new("TextButton");b.Size=UDim2.new(0,42,0,20);b.Position=UDim2.new(1,-48,0.5,-10);b.BorderSizePixel=0;b.TextSize=10;b.Font=Enum.Font.GothamBold;b.Parent=r
 pcall(function() Instance.new("UICorner",b).CornerRadius=UDim.new(0,5) end)
 local function rf() if _G[fl] then b.BackgroundColor3=co or C.ton;b.Text="ON";b.TextColor3=C.tw else b.BackgroundColor3=C.tof;b.Text="OFF";b.TextColor3=C.td end end
 b.MouseButton1Click:Connect(function() _G[fl]=not _G[fl];rf() end);rf()
end
local function mBtn(p,t,c,cb,o) local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,28);b.BackgroundColor3=c or C.bl;b.Text=t;b.TextColor3=C.tw;b.TextSize=11;b.Font=Enum.Font.GothamBold;b.BorderSizePixel=0;b.LayoutOrder=o or 0;b.Parent=p;pcall(function() Instance.new("UICorner",b).CornerRadius=UDim.new(0,6) end);b.MouseButton1Click:Connect(cb);return b end
local logQ,logLbl={},nil
local function log(m) print("[LP] "..tostring(m));table.insert(logQ,tostring(m));if #logQ>6 then table.remove(logQ,1) end;if logLbl then logLbl.Text=table.concat(logQ,"\n") end end
pcall(function()
 local pg=tP["Dashboard"]
 mSec(pg,"* LEGENDARY PARADISE *",1);mLbl(pg,"Case Paradise v2.0 - JJSploit",2)
 mSec(pg,"PLAYER INFO",3);local il=mLbl(pg,"Loading...",4)
 mSec(pg,"GROUP CASE",5);mLbl(pg,GC and("Found: "..tostring(GC)) or "Not found - join group!",6)
 mSec(pg,"STATS",7);local sl=mLbl(pg,"Sessions:0 Cases:0 $0",8)
 mSec(pg,"LOG",9)
 local lb=Instance.new("Frame");lb.Size=UDim2.new(1,0,0,80);lb.BackgroundColor3=C.lb;lb.BorderSizePixel=0;lb.LayoutOrder=10;lb.Parent=pg
 pcall(function() Instance.new("UICorner",lb).CornerRadius=UDim.new(0,6) end)
 logLbl=Instance.new("TextLabel");logLbl.Size=UDim2.new(1,-8,1,-4);logLbl.Position=UDim2.new(0,4,0,2);logLbl.BackgroundTransparency=1;logLbl.Text="Starting...";logLbl.TextColor3=Color3.fromRGB(160,220,160);logLbl.TextSize=10;logLbl.Font=Enum.Font.Code;logLbl.TextXAlignment=Enum.TextXAlignment.Left;logLbl.TextYAlignment=Enum.TextYAlignment.Top;logLbl.TextWrapped=true;logLbl.Parent=lb
 coroutine.resume(coroutine.create(function() while wait(2) do pcall(function() il.Text="Lv:"..tostring(gLvl()).." | $"..tostring(math.floor(gBal()));sl.Text="Ses:"..st.sessions.." Cases:"..st.casesOpened.." $"..math.floor(st.earned) end) end end))
end)
pcall(function()
 local pg=tP["Automation"]
 mSec(pg,"FARMING",1);mTog(pg,"Auto Farm (Group Cases)","LP_FARM",C.bl,2);mLbl(pg,"5 cases x 5 rounds",3)
 mSec(pg,"AUTO SELL",5);mTog(pg,"Auto Sell (keep >$900)","LP_SELL",C.or2,6)
 mSec(pg,"LEVEL CASES",8);mTog(pg,"Auto Level Cases","LP_LEVEL",C.gn,9)
 mSec(pg,"QUESTS",11);mTog(pg,"Auto Quests","LP_QUESTS",C.pu,12)
 mSec(pg,"EVENTS",14);mTog(pg,"Auto Event (Meteorites)","LP_EVENT",C.pu,15)
 mSec(pg,"BONUSES",17);mTog(pg,"Auto Exchange","LP_EXCHANGE",C.gn,18);mTog(pg,"Auto Gifts","LP_GIFTS",C.gn,19)
 mSec(pg,"QUICK",20)
 mBtn(pg,"Activate ALL",C.gn,function() _G.LP_FARM=true;_G.LP_SELL=true;_G.LP_EVENT=true;_G.LP_LEVEL=true;_G.LP_QUESTS=true;_G.LP_EXCHANGE=true;_G.LP_GIFTS=true;log("All ON");swT("Automation") end,21)
 mBtn(pg,"Deactivate ALL",C.rd,function() _G.LP_FARM=false;_G.LP_SELL=false;_G.LP_EVENT=false;_G.LP_LEVEL=false;_G.LP_QUESTS=false;_G.LP_EXCHANGE=false;_G.LP_GIFTS=false;log("All OFF");swT("Automation") end,22)
end)
pcall(function()
 local pg=tP["Battles"]
 local acn={}
 if Cases then for id,d in pairs(Cases) do if type(d)=="table" and d.Name then local pr=d.Price or 0;table.insert(acn,{id=id,name=d.Name,price=pr}) end end;table.sort(acn,function(a,b) return a.price<b.price end) end
 local bm={"CLASSIC","TERMINAL","CRAZY TERMINAL","SHARED","JESTER","JACKPOT","CRAZY JACKPOT"}
 mSec(pg,"MANUAL BATTLE",1)
 local sr=Instance.new("Frame");sr.Size=UDim2.new(1,0,0,26);sr.BackgroundColor3=C.cd;sr.BorderSizePixel=0;sr.LayoutOrder=2;sr.Parent=pg
 pcall(function() Instance.new("UICorner",sr).CornerRadius=UDim.new(0,6) end)
 local sb2=Instance.new("TextBox");sb2.Size=UDim2.new(1,-8,1,0);sb2.Position=UDim2.new(0,4,0,0);sb2.BackgroundTransparency=1;sb2.Text="";sb2.PlaceholderText="Search case...";sb2.TextColor3=C.tw;sb2.PlaceholderColor3=C.td;sb2.TextSize=11;sb2.Font=Enum.Font.Gotham;sb2.TextXAlignment=Enum.TextXAlignment.Left;sb2.ClearTextOnFocus=false;sb2.Parent=sr
 local scl=mLbl(pg,"Selected: (none)",3);scl.TextColor3=C.ac
 local clf=Instance.new("Frame");clf.Size=UDim2.new(1,0,0,120);clf.BackgroundColor3=Color3.fromRGB(15,15,19);clf.BorderSizePixel=0;clf.LayoutOrder=4;clf.Parent=pg
 pcall(function() Instance.new("UICorner",clf).CornerRadius=UDim.new(0,6) end)
 local csc=Instance.new("ScrollingFrame");csc.Size=UDim2.new(1,-4,1,-4);csc.Position=UDim2.new(0,2,0,2);csc.BackgroundTransparency=1;csc.BorderSizePixel=0;csc.ScrollBarThickness=3;csc.CanvasSize=UDim2.new(0,0,0,math.max(500,#acn*24+10));csc.Parent=clf
 local cL=Instance.new("UIListLayout");cL.SortOrder=Enum.SortOrder.LayoutOrder;cL.Padding=UDim.new(0,2);cL.Parent=csc
 pcall(function() cL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() csc.CanvasSize=UDim2.new(0,0,0,cL.AbsoluteContentSize.Y+4) end) end)
 local cBs={}
 local function selC(n,id) _G.LP_BATTLE_CASE=id;scl.Text="Selected: "..n;for _,i in ipairs(cBs) do if i.id==id then i.btn.BackgroundColor3=C.ac;i.btn.TextColor3=Color3.fromRGB(0,0,0) else i.btn.BackgroundColor3=C.cd;i.btn.TextColor3=C.tx end end end
 for idx,e in ipairs(acn) do
  local cb=Instance.new("TextButton");cb.Size=UDim2.new(1,-4,0,22);cb.BackgroundColor3=C.cd;cb.Text=e.name..(e.price>0 and(" $"..e.price) or " FREE");cb.TextColor3=C.tx;cb.TextSize=10;cb.Font=Enum.Font.Gotham;cb.TextXAlignment=Enum.TextXAlignment.Left;cb.BorderSizePixel=0;cb.LayoutOrder=idx;cb.Parent=csc
  pcall(function() Instance.new("UICorner",cb).CornerRadius=UDim.new(0,4) end)
  table.insert(cBs,{btn=cb,name=e.name,id=e.id,price=e.price})
  cb.MouseButton1Click:Connect(function() selC(e.name,e.id) end)
 end
 local function filt() local q=string.lower(sb2.Text);for _,i in ipairs(cBs) do i.btn.Visible=(q=="" or string.find(string.lower(i.name),q,1,true)~=nil) end end
 sb2.FocusLost:Connect(filt);pcall(function() sb2:GetPropertyChangedSignal("Text"):Connect(filt) end)
 mSec(pg,"MODE",5)
 local mf=Instance.new("Frame");mf.Size=UDim2.new(1,0,0,52);mf.BackgroundTransparency=1;mf.LayoutOrder=6;mf.Parent=pg
 local mBs={}
 for i,m in ipairs(bm) do
  local col=math.ceil(i/4);local row=((i-1)%4)
  local mb2=Instance.new("TextButton");mb2.Size=UDim2.new(0.245,-2,0,22);mb2.Position=UDim2.new(row*0.25,1,0,(col-1)*26);mb2.BackgroundColor3=(m=="CRAZY TERMINAL") and C.ac or C.cd;mb2.Text=m;mb2.TextColor3=(m=="CRAZY TERMINAL") and Color3.fromRGB(0,0,0) or C.tx;mb2.TextSize=9;mb2.Font=Enum.Font.GothamBold;mb2.BorderSizePixel=0;mb2.Parent=mf
  pcall(function() Instance.new("UICorner",mb2).CornerRadius=UDim.new(0,5) end)
  mBs[m]=mb2
  mb2.MouseButton1Click:Connect(function() _G.LP_BATTLE_MODE=m;for k,v in pairs(mBs) do if k==m then v.BackgroundColor3=C.ac;v.TextColor3=Color3.fromRGB(0,0,0) else v.BackgroundColor3=C.cd;v.TextColor3=C.tx end end;log("Mode: "..m) end)
 end
 mBtn(pg,"CREATE BATTLE",C.bl,function()
  if _G.LP_BATTLE_CASE=="" then log("Select case!");return end
  if not cbR then log("No remote");return end
  log("Battle: ".._G.LP_BATTLE_CASE.." | ".._G.LP_BATTLE_MODE)
  local bid;pcall(function() bid=cbR:InvokeServer({tostring(_G.LP_BATTLE_CASE)},2,_G.LP_BATTLE_MODE,false) end)
  if bid and abR then wait(0.6);pcall(function() abR:FireServer(tonumber(bid),LP) end);log("Created #"..tostring(bid));st.battlesPlayed=st.battlesPlayed+1 else log("Failed") end
 end,7)
 mSec(pg,"AUTO BATTLE",10);mLbl(pg,"Budget + min balance + risk",11)
 local br=Instance.new("Frame");br.Size=UDim2.new(1,0,0,26);br.BackgroundColor3=C.cd;br.BorderSizePixel=0;br.LayoutOrder=12;br.Parent=pg
 pcall(function() Instance.new("UICorner",br).CornerRadius=UDim.new(0,6) end)
 local bl2=Instance.new("TextLabel");bl2.Size=UDim2.new(0,90,1,0);bl2.Position=UDim2.new(0,8,0,0);bl2.BackgroundTransparency=1;bl2.Text="Budget $";bl2.TextColor3=C.tx;bl2.TextSize=11;bl2.Font=Enum.Font.Gotham;bl2.TextXAlignment=Enum.TextXAlignment.Left;bl2.Parent=br
 local bb=Instance.new("TextBox");bb.Size=UDim2.new(1,-100,1,-4);bb.Position=UDim2.new(0,95,0,2);bb.BackgroundColor3=Color3.fromRGB(30,30,36);bb.Text="500";bb.TextColor3=C.ac;bb.TextSize=11;bb.Font=Enum.Font.GothamBold;bb.BorderSizePixel=0;bb.ClearTextOnFocus=false;bb.Parent=br
 pcall(function() Instance.new("UICorner",bb).CornerRadius=UDim.new(0,4) end)
 bb.FocusLost:Connect(function() _G.LP_BATTLE_BUDGET=tonumber(bb.Text) or 500;log("Budget: $".._G.LP_BATTLE_BUDGET) end)
 local mr=Instance.new("Frame");mr.Size=UDim2.new(1,0,0,26);mr.BackgroundColor3=C.cd;mr.BorderSizePixel=0;mr.LayoutOrder=13;mr.Parent=pg
 pcall(function() Instance.new("UICorner",mr).CornerRadius=UDim.new(0,6) end)
 local ml=Instance.new("TextLabel");ml.Size=UDim2.new(0,90,1,0);ml.Position=UDim2.new(0,8,0,0);ml.BackgroundTransparency=1;ml.Text="Min Bal $";ml.TextColor3=C.tx;ml.TextSize=11;ml.Font=Enum.Font.Gotham;ml.TextXAlignment=Enum.TextXAlignment.Left;ml.Parent=mr
 local mb3=Instance.new("TextBox");mb3.Size=UDim2.new(1,-100,1,-4);mb3.Position=UDim2.new(0,95,0,2);mb3.BackgroundColor3=Color3.fromRGB(30,30,36);mb3.Text="100";mb3.TextColor3=C.ac;mb3.TextSize=11;mb3.Font=Enum.Font.GothamBold;mb3.BorderSizePixel=0;mb3.ClearTextOnFocus=false;mb3.Parent=mr
 pcall(function() Instance.new("UICorner",mb3).CornerRadius=UDim.new(0,4) end)
 mb3.FocusLost:Connect(function() _G.LP_BATTLE_MIN_BAL=tonumber(mb3.Text) or 100;log("Min bal: $".._G.LP_BATTLE_MIN_BAL) end)
 mLbl(pg,"Risk:",14)
 local rf=Instance.new("Frame");rf.Size=UDim2.new(1,0,0,26);rf.BackgroundTransparency=1;rf.LayoutOrder=15;rf.Parent=pg
 local rLs={{n="Low",c=C.gn},{n="Medium",c=C.or2},{n="High",c=C.rd}};local rBs={}
 for i,r in ipairs(rLs) do
  local rb=Instance.new("TextButton");rb.Size=UDim2.new(0.32,-2,1,0);rb.Position=UDim2.new((i-1)*0.34,1,0,0);rb.BackgroundColor3=r.n=="Medium" and r.c or C.cd;rb.Text=r.n;rb.TextColor3=r.n=="Medium" and C.tw or C.tx;rb.TextSize=11;rb.Font=Enum.Font.GothamBold;rb.BorderSizePixel=0;rb.Parent=rf
  pcall(function() Instance.new("UICorner",rb).CornerRadius=UDim.new(0,5) end)
  rBs[r.n]={btn=rb,color=r.c}
  rb.MouseButton1Click:Connect(function() _G.LP_BATTLE_RISK=r.n;for rn,rv in pairs(rBs) do if rn==r.n then rv.btn.BackgroundColor3=rv.color;rv.btn.TextColor3=C.tw else rv.btn.BackgroundColor3=C.cd;rv.btn.TextColor3=C.tx end end;log("Risk: "..r.n) end)
 end
 mTog(pg,"Auto Battle","LP_AUTOBATTLE",C.pu,16)
 mSec(pg,"BATTLE STATS",17);local bsl=mLbl(pg,"P:0 W:0 L:0 $0",18)
 mBtn(pg,"Reset Stats",C.rd,function() st.battlesPlayed=0;st.battlesWon=0;st.battlesLost=0;st.battleProfit=0;log("Reset") end,19)
 coroutine.resume(coroutine.create(function() while wait(2) do pcall(function() bsl.Text="P:"..st.battlesPlayed.." W:"..st.battlesWon.." L:"..st.battlesLost.." $"..math.floor(st.battleProfit) end) end end))
end)
pcall(function()
 local pg=tP["Upgrader"]
 mSec(pg,"SMART UPGRADER",1);mTog(pg,"Auto Upgrader","LP_UPGRADER",C.or2,2);mLbl(pg,"Upgrades cheapest items",3)
 mSec(pg,"MULTIPLIER",4)
 local mBs2={};local mr2=Instance.new("Frame");mr2.Size=UDim2.new(1,0,0,26);mr2.BackgroundTransparency=1;mr2.LayoutOrder=5;mr2.Parent=pg
 for i,m in ipairs({2,3,5,10}) do
  local b=Instance.new("TextButton");b.Size=UDim2.new(0.24,-3,1,0);b.Position=UDim2.new((i-1)*0.25,2,0,0);b.BackgroundColor3=m==2 and C.ac or C.cd;b.Text=m.."x";b.TextColor3=m==2 and Color3.fromRGB(0,0,0) or C.tx;b.TextSize=11;b.Font=Enum.Font.GothamBold;b.BorderSizePixel=0;b.Parent=mr2
  pcall(function() Instance.new("UICorner",b).CornerRadius=UDim.new(0,5) end);mBs2[m]=b
  b.MouseButton1Click:Connect(function() _G.LP_UPGRADER_MULT=m;for k,v in pairs(mBs2) do if k==m then v.BackgroundColor3=C.ac;v.TextColor3=Color3.fromRGB(0,0,0) else v.BackgroundColor3=C.cd;v.TextColor3=C.tx end end;log("Mult: "..m.."x") end)
 end
 mSec(pg,"STATS",6);local us=mLbl(pg,"A:0 W:0 L:0 $0",7)
 mBtn(pg,"Reset Stats",C.rd,function() st.upgAttempts=0;st.upgWins=0;st.upgLosses=0;st.upgProfit=0;log("Reset") end,8)
 coroutine.resume(coroutine.create(function() while wait(2) do pcall(function() us.Text="A:"..st.upgAttempts.." W:"..st.upgWins.." L:"..st.upgLosses.." $"..math.floor(st.upgProfit) end) end end))
end)
pcall(function()
 local pg=tP["Exploits"]
 mSec(pg,"CHANGERS (Client Only)",1)
 mBtn(pg,"Money $999,999",C.bl,function() pcall(function() local pd=LP:FindFirstChild("PlayerData");local c=pd and pd:FindFirstChild("Currencies");local b=c and c:FindFirstChild("Balance");if b then b.Value=999999;log("$999,999") end end) end,2)
 mBtn(pg,"Tickets 9,999",C.pu,function() pcall(function() local pd=LP:FindFirstChild("PlayerData");local c=pd and pd:FindFirstChild("Currencies");local t=c and c:FindFirstChild("Tickets");if t then t.Value=9999;log("Tix 9999") end end) end,3)
 mSec(pg,"DUPLICATION",5);mLbl(pg,"Client-side clones",6)
 mBtn(pg,"Duplicate All (x1)",C.or2,function() local inv=gInv();if not inv then log("No inv");return end;local n=0;for _,i in ipairs(inv:GetChildren()) do if not i:GetAttribute("LPDuplicated") then local cl=i:Clone();cl:SetAttribute("LPDuplicated",true);cl.Parent=inv;n=n+1 end end;log("Duped "..n) end,7)
 mBtn(pg,"Remove Clones",C.rd,function() local inv=gInv();if not inv then return end;local n=0;for _,i in ipairs(inv:GetChildren()) do if i:GetAttribute("LPDuplicated") then i:Destroy();n=n+1 end end;log("Removed "..n) end,8)
end)
pcall(function()
 local pg=tP["Settings"]
 mSec(pg,"GENERAL",1);mTog(pg,"Anti-AFK","LP_ANTIAFK",C.gn,2);mLbl(pg,"Auto-click on idle",3)
 mSec(pg,"INFO",5);mLbl(pg,"* LEGENDARY PARADISE * v2.0",6);mLbl(pg,"JJSploit Compatible",7);mLbl(pg,"by LegendaryRvx",8)
 mSec(pg,"DESTROY",10);mBtn(pg,"Destroy GUI",C.rd,function() sg:Destroy() end,11)
end)
swT("Dashboard")
log("* LEGENDARY PARADISE * loaded!")
log("Lv:"..tostring(gLvl()).." $"..tostring(math.floor(gBal())))
if GC then log("Group: "..tostring(GC)) else log("No group case") end
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_FARM and GC and ocR then
   pcall(function()
    st.sessions=st.sessions+1;log("Farm #"..st.sessions)
    for r=1,(_G.LP_ROUNDS_PER_SESSION or 5) do
     if not _G.LP_FARM then break end
     for c=1,(_G.LP_CASES_PER_ROUND or 5) do
      if not _G.LP_FARM then break end
      pcall(function() ocR:InvokeServer(GC) end);st.casesOpened=st.casesOpened+1;wait(0.3)
     end
     wait(0.5)
    end
    log("Farm done")
   end)
   wait(2)
  end
 end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_SELL and slR then
   pcall(function()
    local inv=gInv();if not inv then return end
    local kp=_G.LP_KEEP_ABOVE_PRICE or 900;local n=0
    for _,i in ipairs(inv:GetChildren()) do
     if not _G.LP_SELL then break end
     local p=gPrice(i);if p<kp and p>0 then pcall(function() slR:InvokeServer(i) end);st.earned=st.earned+p;n=n+1;wait(0.1) end
    end
    if n>0 then log("Sold "..n) end
   end)
   wait(3)
  end
 end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_LEVEL and ocR then
   pcall(function()
    if Cases then
     local cc=nil;local cp=math.huge
     for id,d in pairs(Cases) do
      if type(d)=="table" and d.Price then
       if d.Price<cp and d.Price>0 then cp=d.Price;cc=id end
      end
     end
     if cc then
      local bal=gBal();if bal>=cp then pcall(function() ocR:InvokeServer(cc) end);st.casesOpened=st.casesOpened+1;log("LvlCase opened") end
     end
    end
   end)
   wait(2)
  end
 end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_QUESTS then
   pcall(function()
    if Rem then
     local cq=Rem:FindFirstChild("ClaimQuest") or Rem:FindFirstChild("CompleteQuest")
     if cq then for i=1,5 do pcall(function() cq:FireServer(i) end);wait(0.2) end;log("Quests claimed") end
    end
   end)
   wait(10)
  end
 end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_EVENT then
   pcall(function()
    local met=WS:FindFirstChild("Meteorites") or WS:FindFirstChild("Events")
    if met then
     for _,m in ipairs(met:GetChildren()) do
      if not _G.LP_EVENT then break end
      pcall(function()
       local cd=m:FindFirstChild("ClickDetector")
       if cd then fireclickdetector(cd) end
       local pp=m:FindFirstChild("ProximityPrompt")
       if pp then fireproximityprompt(pp) end
      end)
      wait(0.2)
     end
     log("Events done")
    end
   end)
   wait(5)
  end
 end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_EXCHANGE and exR then
   pcall(function() exR:FireServer() end);log("Exchange");wait(10)
  end
 end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_GIFTS then
   pcall(function()
    if urR then pcall(function() urR:FireServer() end) end
    if Rem then
     local cr=Rem:FindFirstChild("CollectReward") or Rem:FindFirstChild("ClaimGift")
     if cr then pcall(function() cr:FireServer() end) end
    end
    log("Gifts")
   end)
   wait(15)
  end
 end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_UPGRADER and upR then
   pcall(function()
    local inv=gInv();if not inv then return end
    local best=nil;local bp=math.huge
    local mn2=_G.LP_UPGRADER_MIN_PRICE or 0;local mx=_G.LP_UPGRADER_MAX_PRICE or 50
    for _,i in ipairs(inv:GetChildren()) do
     local p=gPrice(i);if p>=mn2 and p<=mx and p<bp then bp=p;best=i end
    end
    if best then
     local m=_G.LP_UPGRADER_MULT or 2
     st.upgAttempts=st.upgAttempts+1
     local r=upR:InvokeServer(best,m)
     if r and r.Success then st.upgWins=st.upgWins+1;st.upgProfit=st.upgProfit+(bp*(m-1));log("Upg WIN "..m.."x") else st.upgLosses=st.upgLosses+1;st.upgProfit=st.upgProfit-bp;log("Upg LOSS") end
    end
   end)
   wait(1.5)
  end
 end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_AUTOBATTLE and cbR and abR then
   pcall(function()
    local bg=_G.LP_BATTLE_BUDGET or 500
    local mmb2=_G.LP_BATTLE_MIN_BAL or 100
    local rk=_G.LP_BATTLE_RISK or "Medium"
    local bal=gBal();local avail=bal-mmb2;if avail<10 then log("Low bal");wait(5);return end
    local cs2=_G.LP_BATTLE_CASE
    if cs2=="" and Cases then
     local cn={};for id,d in pairs(Cases) do if type(d)=="table" and d.Price and d.Price>0 then table.insert(cn,{id=id,price=d.Price}) end end
     table.sort(cn,function(a,b) return a.price<b.price end)
     if rk=="Low" then
      for _,c in ipairs(cn) do if c.price<=math.min(bg,avail)*0.3 then cs2=c.id end end
     elseif rk=="High" then
      for i=#cn,1,-1 do if cn[i].price<=math.min(bg,avail)*0.8 then cs2=cn[i].id;break end end
     else
      for _,c in ipairs(cn) do if c.price<=math.min(bg,avail)*0.5 then cs2=c.id end end
     end
    end
    if cs2 and cs2~="" then
     local md=_G.LP_BATTLE_MODE or "CRAZY TERMINAL"
     local bid;pcall(function() bid=cbR:InvokeServer({tostring(cs2)},2,md,false) end)
     if bid then wait(0.6);pcall(function() abR:FireServer(tonumber(bid),LP) end);st.battlesPlayed=st.battlesPlayed+1;log("A-Battle #"..st.battlesPlayed) end
    end
   end)
   wait(4)
  end
 end
end))
coroutine.resume(coroutine.create(function()
 while wait(1) do
  if _G.LP_ANTIAFK then
   pcall(function()
    local vu=game:GetService("VirtualUser")
    vu:CaptureController();vu:ClickButton2(Vector2.new())
   end)
   wait(30)
  end
 end
end))
log("All systems ready!")
print("[LP] * LEGENDARY PARADISE * fully loaded!")
