



<!DOCTYPE html>
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" >
 <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" >
 
 <meta name="ROBOTS" content="NOARCHIVE">
 
 <link rel="icon" type="image/vnd.microsoft.icon" href="https://ssl.gstatic.com/codesite/ph/images/phosting.ico">
 
 
 <script type="text/javascript">
 
 
 
 
 var codesite_token = "ABZ6GAeC5X_a7K1BFjPgTkyfTKi2mFfewQ:1410858437809";
 
 
 var CS_env = {"token": "ABZ6GAeC5X_a7K1BFjPgTkyfTKi2mFfewQ:1410858437809", "profileUrl": "/u/105489876805901808296/", "projectName": "baphy", "assetHostPath": "https://ssl.gstatic.com/codesite/ph", "domainName": null, "projectHomeUrl": "/p/baphy", "assetVersionPath": "https://ssl.gstatic.com/codesite/ph/17097911804237236952", "loggedInUserEmail": "boubenec@gmail.com", "relativeBaseUrl": ""};
 var _gaq = _gaq || [];
 _gaq.push(
 ['siteTracker._setAccount', 'UA-18071-1'],
 ['siteTracker._trackPageview']);
 
 (function() {
 var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
 ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
 (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(ga);
 })();
 
 </script>
 
 
 <title>ObjLoadSaveDefaults.m - 
 baphy -
 
 
 Behavioral Auditory PHYsiology - Google Project Hosting
 </title>
 <link type="text/css" rel="stylesheet" href="https://ssl.gstatic.com/codesite/ph/17097911804237236952/css/core.css">
 
 <link type="text/css" rel="stylesheet" href="https://ssl.gstatic.com/codesite/ph/17097911804237236952/css/ph_detail.css" >
 
 
 <link type="text/css" rel="stylesheet" href="https://ssl.gstatic.com/codesite/ph/17097911804237236952/css/d_sb.css" >
 
 
 
<!--[if IE]>
 <link type="text/css" rel="stylesheet" href="https://ssl.gstatic.com/codesite/ph/17097911804237236952/css/d_ie.css" >
<![endif]-->
 <style type="text/css">
 .menuIcon.off { background: no-repeat url(https://ssl.gstatic.com/codesite/ph/images/dropdown_sprite.gif) 0 -42px }
 .menuIcon.on { background: no-repeat url(https://ssl.gstatic.com/codesite/ph/images/dropdown_sprite.gif) 0 -28px }
 .menuIcon.down { background: no-repeat url(https://ssl.gstatic.com/codesite/ph/images/dropdown_sprite.gif) 0 0; }
 
 
 
  tr.inline_comment {
 background: #fff;
 vertical-align: top;
 }
 div.draft, div.published {
 padding: .3em;
 border: 1px solid #999; 
 margin-bottom: .1em;
 font-family: arial, sans-serif;
 max-width: 60em;
 }
 div.draft {
 background: #ffa;
 } 
 div.published {
 background: #e5ecf9;
 }
 div.published .body, div.draft .body {
 padding: .5em .1em .1em .1em;
 max-width: 60em;
 white-space: pre-wrap;
 white-space: -moz-pre-wrap;
 white-space: -pre-wrap;
 white-space: -o-pre-wrap;
 word-wrap: break-word;
 font-size: 1em;
 }
 div.draft .actions {
 margin-left: 1em;
 font-size: 90%;
 }
 div.draft form {
 padding: .5em .5em .5em 0;
 }
 div.draft textarea, div.published textarea {
 width: 95%;
 height: 10em;
 font-family: arial, sans-serif;
 margin-bottom: .5em;
 }

 
 .nocursor, .nocursor td, .cursor_hidden, .cursor_hidden td {
 background-color: white;
 height: 2px;
 }
 .cursor, .cursor td {
 background-color: darkblue;
 height: 2px;
 display: '';
 }
 
 
.list {
 border: 1px solid white;
 border-bottom: 0;
}

 
 </style>
</head>
<body class="t4">
<script type="text/javascript">
 window.___gcfg = {lang: 'en'};
 (function() 
 {var po = document.createElement("script");
 po.type = "text/javascript"; po.async = true;po.src = "https://apis.google.com/js/plusone.js";
 var s = document.getElementsByTagName("script")[0];
 s.parentNode.insertBefore(po, s);
 })();
</script>
<div class="headbg">

 <div id="gaia">
 

 <span>
 
 
 
 <a href="#" id="multilogin-dropdown" onclick="return false;"
 ><u><b>boubenec@gmail.com</b></u> <small>&#9660;</small></a>
 
 
 | <a href="/u/105489876805901808296/" id="projects-dropdown" onclick="return false;"
 ><u>My favorites</u> <small>&#9660;</small></a>
 | <a href="/u/105489876805901808296/" onclick="_CS_click('/gb/ph/profile');"
 title="Profile, Updates, and Settings"
 ><u>Profile</u></a>
 | <a href="https://www.google.com/accounts/Logout?continue=https%3A%2F%2Fcode.google.com%2Fp%2Fbaphy%2Fsource%2Fbrowse%2FConfig%2Flbhb%2FTrialObjects%2F%40RefTarOpt%2FObjLoadSaveDefaults.m" 
 onclick="_CS_click('/gb/ph/signout');"
 ><u>Sign out</u></a>
 
 </span>

 </div>

 <div class="gbh" style="left: 0pt;"></div>
 <div class="gbh" style="right: 0pt;"></div>
 
 
 <div style="height: 1px"></div>
<!--[if lte IE 7]>
<div style="text-align:center;">
Your version of Internet Explorer is not supported. Try a browser that
contributes to open source, such as <a href="http://www.firefox.com">Firefox</a>,
<a href="http://www.google.com/chrome">Google Chrome</a>, or
<a href="http://code.google.com/chrome/chromeframe/">Google Chrome Frame</a>.
</div>
<![endif]-->



 <table style="padding:0px; margin: 0px 0px 10px 0px; width:100%" cellpadding="0" cellspacing="0"
 itemscope itemtype="http://schema.org/CreativeWork">
 <tr style="height: 58px;">
 
 
 
 <td id="plogo">
 <link itemprop="url" href="/p/baphy">
 <a href="/p/baphy/">
 
 <img src="https://ssl.gstatic.com/codesite/ph/images/defaultlogo.png" alt="Logo" itemprop="image">
 
 </a>
 </td>
 
 <td style="padding-left: 0.5em">
 
 <div id="pname">
 <a href="/p/baphy/"><span itemprop="name">baphy</span></a>
 </div>
 
 <div id="psum">
 <a id="project_summary_link"
 href="/p/baphy/"><span itemprop="description">Behavioral Auditory PHYsiology</span></a>
 
 </div>
 
 
 </td>
 <td style="white-space:nowrap;text-align:right; vertical-align:bottom;">
 
 <form action="/hosting/search">
 <input size="30" name="q" value="" type="text">
 
 <input type="submit" name="projectsearch" value="Search projects" >
 </form>
 
 </tr>
 </table>

</div>

 
<div id="mt" class="gtb"> 
 <a href="/p/baphy/" class="tab ">Project&nbsp;Home</a>
 
 
 
 
 
 
 <a href="/p/baphy/w/list" class="tab ">Wiki</a>
 
 
 
 
 
 <a href="/p/baphy/issues/list"
 class="tab ">Issues</a>
 
 
 
 
 
 <a href="/p/baphy/source/checkout"
 class="tab active">Source</a>
 
 
 
 
 
 
 
 
 <div class=gtbc></div>
</div>
<table cellspacing="0" cellpadding="0" width="100%" align="center" border="0" class="st">
 <tr>
 
 
 
 
 
 
 <td class="subt">
 <div class="st2">
 <div class="isf">
 
 <form action="/p/baphy/source/browse" style="display: inline">
 
 Repository:
 <select name="repo" id="repo" style="font-size: 92%" onchange="submit()">
 <option value="default">default</option><option value="wiki">wiki</option>
 </select>
 </form>
 
 


 <span class="inst1"><a href="/p/baphy/source/checkout">Checkout</a></span> &nbsp;
 <span class="inst2"><a href="/p/baphy/source/browse/">Browse</a></span> &nbsp;
 <span class="inst3"><a href="/p/baphy/source/list">Changes</a></span> &nbsp;
 <span class="inst4"><a href="/p/baphy/source/clones">Clones</a></span> &nbsp; 
 
 
 
 
 <a href="/p/baphy/issues/entry?show=review&former=sourcelist">Request code review</a>
 
 
 
 </form>
 <script type="text/javascript">
 
 function codesearchQuery(form) {
 var query = document.getElementById('q').value;
 if (query) { form.action += '%20' + query; }
 }
 </script>
 </div>
</div>

 </td>
 
 
 
 <td align="right" valign="top" class="bevel-right"></td>
 </tr>
</table>


<script type="text/javascript">
 var cancelBubble = false;
 function _go(url) { document.location = url; }
</script>
<div id="maincol"
 
>

 




<div class="expand">
<div id="colcontrol">
<style type="text/css">
 #file_flipper { white-space: nowrap; padding-right: 2em; }
 #file_flipper.hidden { display: none; }
 #file_flipper .pagelink { color: #0000CC; text-decoration: underline; }
 #file_flipper #visiblefiles { padding-left: 0.5em; padding-right: 0.5em; }
</style>
<table id="nav_and_rev" class="list"
 cellpadding="0" cellspacing="0" width="100%">
 <tr>
 
 <td nowrap="nowrap" class="src_crumbs src_nav" width="33%">
 <strong class="src_nav">Source path:&nbsp;</strong>
 <span id="crumb_root">
 
 <a href="/p/baphy/source/browse/">git</a>/&nbsp;</span>
 <span id="crumb_links" class="ifClosed"><a href="/p/baphy/source/browse/Config/">Config</a><span class="sp">/&nbsp;</span><a href="/p/baphy/source/browse/Config/lbhb/">lbhb</a><span class="sp">/&nbsp;</span><a href="/p/baphy/source/browse/Config/lbhb/TrialObjects/">TrialObjects</a><span class="sp">/&nbsp;</span><a href="/p/baphy/source/browse/Config/lbhb/TrialObjects/%40RefTarOpt/">@RefTarOpt</a><span class="sp">/&nbsp;</span>ObjLoadSaveDefaults.m</span>
 
 
 
 
 
 <form class="src_nav">
 
 <span class="sourcelabel"><strong>Branch:</strong>
 <select id="branch_select" name="name" onchange="submit()">
 
 <option value="abcng"
 >
 abcng
 </option>
 
 <option value="master"
 selected>
 master
 </option>
 
 
 </select>
 </span>
 </form>
 
 
 
 
 


 <span class="sourcelabel">Download
 <a href="//baphy.googlecode.com/archive/e8a83f1978e8252fc8f4030b6d6a882f0e87739c.zip" rel="nofollow">zip</a> | <a href="//baphy.googlecode.com/archive/e8a83f1978e8252fc8f4030b6d6a882f0e87739c.tar.gz" rel="nofollow">tar.gz</a>
 </span>


 </td>
 
 
 <td nowrap="nowrap" width="33%" align="center">
 <a href="/p/baphy/source/browse/Config/lbhb/TrialObjects/%40RefTarOpt/ObjLoadSaveDefaults.m?edit=1"
 ><img src="https://ssl.gstatic.com/codesite/ph/images/pencil-y14.png"
 class="edit_icon">Edit file</a>
 </td>
 
 
 <td nowrap="nowrap" width="33%" align="right">
 <table cellpadding="0" cellspacing="0" style="font-size: 100%"><tr>
 
 
 <td class="flipper"><b>e8a83f1978e8</b></td>
 
 <td class="flipper">
 <ul class="rightside">
 
 <li><a href="/p/baphy/source/browse/Config/lbhb/TrialObjects/%40RefTarOpt/ObjLoadSaveDefaults.m?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3" title="Next">5f8ae5ec007e&rsaquo;</a></li>
 
 </ul>
 </td>
 
 </tr></table>
 </td> 
 </tr>
</table>

<div class="fc">
 
 
 
<style type="text/css">
.undermouse span {
 background-image: url(https://ssl.gstatic.com/codesite/ph/images/comments.gif); }
</style>
<table class="opened" id="review_comment_area"
onmouseout="gutterOut()"><tr>
<td id="nums">
<pre><table width="100%"><tr class="nocursor"><td></td></tr></table></pre>
<pre><table width="100%" id="nums_table_0"><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_1"

 onmouseover="gutterOver(1)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',1);">&nbsp;</span
></td><td id="1"><a href="#1">1</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_2"

 onmouseover="gutterOver(2)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',2);">&nbsp;</span
></td><td id="2"><a href="#2">2</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_3"

 onmouseover="gutterOver(3)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',3);">&nbsp;</span
></td><td id="3"><a href="#3">3</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_4"

 onmouseover="gutterOver(4)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',4);">&nbsp;</span
></td><td id="4"><a href="#4">4</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_5"

 onmouseover="gutterOver(5)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',5);">&nbsp;</span
></td><td id="5"><a href="#5">5</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_6"

 onmouseover="gutterOver(6)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',6);">&nbsp;</span
></td><td id="6"><a href="#6">6</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_7"

 onmouseover="gutterOver(7)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',7);">&nbsp;</span
></td><td id="7"><a href="#7">7</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_8"

 onmouseover="gutterOver(8)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',8);">&nbsp;</span
></td><td id="8"><a href="#8">8</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_9"

 onmouseover="gutterOver(9)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',9);">&nbsp;</span
></td><td id="9"><a href="#9">9</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_10"

 onmouseover="gutterOver(10)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',10);">&nbsp;</span
></td><td id="10"><a href="#10">10</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_11"

 onmouseover="gutterOver(11)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',11);">&nbsp;</span
></td><td id="11"><a href="#11">11</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_12"

 onmouseover="gutterOver(12)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',12);">&nbsp;</span
></td><td id="12"><a href="#12">12</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_13"

 onmouseover="gutterOver(13)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',13);">&nbsp;</span
></td><td id="13"><a href="#13">13</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_14"

 onmouseover="gutterOver(14)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',14);">&nbsp;</span
></td><td id="14"><a href="#14">14</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_15"

 onmouseover="gutterOver(15)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',15);">&nbsp;</span
></td><td id="15"><a href="#15">15</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_16"

 onmouseover="gutterOver(16)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',16);">&nbsp;</span
></td><td id="16"><a href="#16">16</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_17"

 onmouseover="gutterOver(17)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',17);">&nbsp;</span
></td><td id="17"><a href="#17">17</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_18"

 onmouseover="gutterOver(18)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',18);">&nbsp;</span
></td><td id="18"><a href="#18">18</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_19"

 onmouseover="gutterOver(19)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',19);">&nbsp;</span
></td><td id="19"><a href="#19">19</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_20"

 onmouseover="gutterOver(20)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',20);">&nbsp;</span
></td><td id="20"><a href="#20">20</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_21"

 onmouseover="gutterOver(21)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',21);">&nbsp;</span
></td><td id="21"><a href="#21">21</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_22"

 onmouseover="gutterOver(22)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',22);">&nbsp;</span
></td><td id="22"><a href="#22">22</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_23"

 onmouseover="gutterOver(23)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',23);">&nbsp;</span
></td><td id="23"><a href="#23">23</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_24"

 onmouseover="gutterOver(24)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',24);">&nbsp;</span
></td><td id="24"><a href="#24">24</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_25"

 onmouseover="gutterOver(25)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',25);">&nbsp;</span
></td><td id="25"><a href="#25">25</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_26"

 onmouseover="gutterOver(26)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',26);">&nbsp;</span
></td><td id="26"><a href="#26">26</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_27"

 onmouseover="gutterOver(27)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',27);">&nbsp;</span
></td><td id="27"><a href="#27">27</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_28"

 onmouseover="gutterOver(28)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',28);">&nbsp;</span
></td><td id="28"><a href="#28">28</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_29"

 onmouseover="gutterOver(29)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',29);">&nbsp;</span
></td><td id="29"><a href="#29">29</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_30"

 onmouseover="gutterOver(30)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',30);">&nbsp;</span
></td><td id="30"><a href="#30">30</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_31"

 onmouseover="gutterOver(31)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',31);">&nbsp;</span
></td><td id="31"><a href="#31">31</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_32"

 onmouseover="gutterOver(32)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',32);">&nbsp;</span
></td><td id="32"><a href="#32">32</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_33"

 onmouseover="gutterOver(33)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',33);">&nbsp;</span
></td><td id="33"><a href="#33">33</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_34"

 onmouseover="gutterOver(34)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',34);">&nbsp;</span
></td><td id="34"><a href="#34">34</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_35"

 onmouseover="gutterOver(35)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',35);">&nbsp;</span
></td><td id="35"><a href="#35">35</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_36"

 onmouseover="gutterOver(36)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',36);">&nbsp;</span
></td><td id="36"><a href="#36">36</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_37"

 onmouseover="gutterOver(37)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',37);">&nbsp;</span
></td><td id="37"><a href="#37">37</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_38"

 onmouseover="gutterOver(38)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',38);">&nbsp;</span
></td><td id="38"><a href="#38">38</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_39"

 onmouseover="gutterOver(39)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',39);">&nbsp;</span
></td><td id="39"><a href="#39">39</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_40"

 onmouseover="gutterOver(40)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',40);">&nbsp;</span
></td><td id="40"><a href="#40">40</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_41"

 onmouseover="gutterOver(41)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',41);">&nbsp;</span
></td><td id="41"><a href="#41">41</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_42"

 onmouseover="gutterOver(42)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',42);">&nbsp;</span
></td><td id="42"><a href="#42">42</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_43"

 onmouseover="gutterOver(43)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',43);">&nbsp;</span
></td><td id="43"><a href="#43">43</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_44"

 onmouseover="gutterOver(44)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',44);">&nbsp;</span
></td><td id="44"><a href="#44">44</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_45"

 onmouseover="gutterOver(45)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',45);">&nbsp;</span
></td><td id="45"><a href="#45">45</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_46"

 onmouseover="gutterOver(46)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',46);">&nbsp;</span
></td><td id="46"><a href="#46">46</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_47"

 onmouseover="gutterOver(47)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',47);">&nbsp;</span
></td><td id="47"><a href="#47">47</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_48"

 onmouseover="gutterOver(48)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',48);">&nbsp;</span
></td><td id="48"><a href="#48">48</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_49"

 onmouseover="gutterOver(49)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',49);">&nbsp;</span
></td><td id="49"><a href="#49">49</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_50"

 onmouseover="gutterOver(50)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',50);">&nbsp;</span
></td><td id="50"><a href="#50">50</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_51"

 onmouseover="gutterOver(51)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',51);">&nbsp;</span
></td><td id="51"><a href="#51">51</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_52"

 onmouseover="gutterOver(52)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',52);">&nbsp;</span
></td><td id="52"><a href="#52">52</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_53"

 onmouseover="gutterOver(53)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',53);">&nbsp;</span
></td><td id="53"><a href="#53">53</a></td></tr
></table></pre>
<pre><table width="100%"><tr class="nocursor"><td></td></tr></table></pre>
</td>
<td id="lines">
<pre><table width="100%"><tr class="cursor_stop cursor_hidden"><td></td></tr></table></pre>
<pre class="prettyprint lang-m"><table id="src_table_0"><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_1

 onmouseover="gutterOver(1)"

><td class="source">function varargout = ObjLoadSaveDefaults (o, action, index)<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_2

 onmouseover="gutterOver(2)"

><td class="source">% function ObjUpdate (o, action, index)<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_3

 onmouseover="gutterOver(3)"

><td class="source">%<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_4

 onmouseover="gutterOver(4)"

><td class="source">% ObjLoadSaveDefaults is a method of class SoundObject and can be used to<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_5

 onmouseover="gutterOver(5)"

><td class="source">% store and load the properties of object o from a file. Multiple profiles<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_6

 onmouseover="gutterOver(6)"

><td class="source">% can be saved and retrieved using index. The defaults are saved in the<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_7

 onmouseover="gutterOver(7)"

><td class="source">% directory of the object o, under the name LastValues.mat<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_8

 onmouseover="gutterOver(8)"

><td class="source">% o: Object<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_9

 onmouseover="gutterOver(9)"

><td class="source">% action: &#39;r&#39; for read, &#39;w&#39; for write<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_10

 onmouseover="gutterOver(10)"

><td class="source">% index: index of profile, default is 1<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_11

 onmouseover="gutterOver(11)"

><td class="source"><br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_12

 onmouseover="gutterOver(12)"

><td class="source">% Nima, november 2005<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_13

 onmouseover="gutterOver(13)"

><td class="source">if nargin&lt;3 , index = 1;end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_14

 onmouseover="gutterOver(14)"

><td class="source">if nargin&lt;2 , action = &#39;r&#39;;end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_15

 onmouseover="gutterOver(15)"

><td class="source">if nargout&gt;0 , varargout{1} = o;end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_16

 onmouseover="gutterOver(16)"

><td class="source">%<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_17

 onmouseover="gutterOver(17)"

><td class="source">object_spec = what(class(o));<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_18

 onmouseover="gutterOver(18)"

><td class="source">fname = [object_spec(1).path filesep &#39;LastValues.mat&#39;];<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_19

 onmouseover="gutterOver(19)"

><td class="source">try<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_20

 onmouseover="gutterOver(20)"

><td class="source">    if exist(fname,&#39;file&#39;)<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_21

 onmouseover="gutterOver(21)"

><td class="source">        load (fname);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_22

 onmouseover="gutterOver(22)"

><td class="source">    else<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_23

 onmouseover="gutterOver(23)"

><td class="source">        values = [];<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_24

 onmouseover="gutterOver(24)"

><td class="source">    end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_25

 onmouseover="gutterOver(25)"

><td class="source">    fields = get(o,&#39;UserDefinableFields&#39;);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_26

 onmouseover="gutterOver(26)"

><td class="source">    if strcmp(action, &#39;w&#39;)<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_27

 onmouseover="gutterOver(27)"

><td class="source">        % get the values first<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_28

 onmouseover="gutterOver(28)"

><td class="source">        cnt2 = 1;<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_29

 onmouseover="gutterOver(29)"

><td class="source">        for cnt1 = 1:length(fields)/3 % fields have name, type and default values.<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_30

 onmouseover="gutterOver(30)"

><td class="source">            values {cnt1,index} = get(o, fields{cnt2});<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_31

 onmouseover="gutterOver(31)"

><td class="source">            cnt2 = cnt2+3;<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_32

 onmouseover="gutterOver(32)"

><td class="source">        end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_33

 onmouseover="gutterOver(33)"

><td class="source">        save (fname, &#39;values&#39;);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_34

 onmouseover="gutterOver(34)"

><td class="source">    elseif ~isempty(values)<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_35

 onmouseover="gutterOver(35)"

><td class="source">        % load the values to the object. if the requested index does not<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_36

 onmouseover="gutterOver(36)"

><td class="source">        % exist, use the first index<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_37

 onmouseover="gutterOver(37)"

><td class="source">        if size(values,2) &lt; index; index = 1; end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_38

 onmouseover="gutterOver(38)"

><td class="source">        cnt2 = 1;<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_39

 onmouseover="gutterOver(39)"

><td class="source">        for cnt1 = 1:length(fields)/3<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_40

 onmouseover="gutterOver(40)"

><td class="source">            if ~isempty(values{cnt1,index})<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_41

 onmouseover="gutterOver(41)"

><td class="source">                % delete the spaces at the end:                 <br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_42

 onmouseover="gutterOver(42)"

><td class="source">                if ischar(values{cnt1,index}) &amp;&amp; strcmpi(values{cnt1,index}(end),&#39; &#39;), values{cnt1,index} = strtok(values{cnt1,index});end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_43

 onmouseover="gutterOver(43)"

><td class="source">                o = set(o,fields{cnt2}, values{cnt1,index});<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_44

 onmouseover="gutterOver(44)"

><td class="source">            else<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_45

 onmouseover="gutterOver(45)"

><td class="source">                o = set(o,fields{cnt2}, get(o,fields{cnt2}));<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_46

 onmouseover="gutterOver(46)"

><td class="source">            end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_47

 onmouseover="gutterOver(47)"

><td class="source">            cnt2 = cnt2 + 3;<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_48

 onmouseover="gutterOver(48)"

><td class="source">        end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_49

 onmouseover="gutterOver(49)"

><td class="source">        varargout{1} = o;<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_50

 onmouseover="gutterOver(50)"

><td class="source">    end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_51

 onmouseover="gutterOver(51)"

><td class="source">catch<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_52

 onmouseover="gutterOver(52)"

><td class="source">    delete(fname);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_53

 onmouseover="gutterOver(53)"

><td class="source">end<br></td></tr
></table></pre>
<pre><table width="100%"><tr class="cursor_stop cursor_hidden"><td></td></tr></table></pre>
</td>
</tr></table>

 
<script type="text/javascript">
 var lineNumUnderMouse = -1;
 
 function gutterOver(num) {
 gutterOut();
 var newTR = document.getElementById('gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_' + num);
 if (newTR) {
 newTR.className = 'undermouse';
 }
 lineNumUnderMouse = num;
 }
 function gutterOut() {
 if (lineNumUnderMouse != -1) {
 var oldTR = document.getElementById(
 'gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_' + lineNumUnderMouse);
 if (oldTR) {
 oldTR.className = '';
 }
 lineNumUnderMouse = -1;
 }
 }
 var numsGenState = {table_base_id: 'nums_table_'};
 var srcGenState = {table_base_id: 'src_table_'};
 var alignerRunning = false;
 var startOver = false;
 function setLineNumberHeights() {
 if (alignerRunning) {
 startOver = true;
 return;
 }
 numsGenState.chunk_id = 0;
 numsGenState.table = document.getElementById('nums_table_0');
 numsGenState.row_num = 0;
 if (!numsGenState.table) {
 return; // Silently exit if no file is present.
 }
 srcGenState.chunk_id = 0;
 srcGenState.table = document.getElementById('src_table_0');
 srcGenState.row_num = 0;
 alignerRunning = true;
 continueToSetLineNumberHeights();
 }
 function rowGenerator(genState) {
 if (genState.row_num < genState.table.rows.length) {
 var currentRow = genState.table.rows[genState.row_num];
 genState.row_num++;
 return currentRow;
 }
 var newTable = document.getElementById(
 genState.table_base_id + (genState.chunk_id + 1));
 if (newTable) {
 genState.chunk_id++;
 genState.row_num = 0;
 genState.table = newTable;
 return genState.table.rows[0];
 }
 return null;
 }
 var MAX_ROWS_PER_PASS = 1000;
 function continueToSetLineNumberHeights() {
 var rowsInThisPass = 0;
 var numRow = 1;
 var srcRow = 1;
 while (numRow && srcRow && rowsInThisPass < MAX_ROWS_PER_PASS) {
 numRow = rowGenerator(numsGenState);
 srcRow = rowGenerator(srcGenState);
 rowsInThisPass++;
 if (numRow && srcRow) {
 if (numRow.offsetHeight != srcRow.offsetHeight) {
 numRow.firstChild.style.height = srcRow.offsetHeight + 'px';
 }
 }
 }
 if (rowsInThisPass >= MAX_ROWS_PER_PASS) {
 setTimeout(continueToSetLineNumberHeights, 10);
 } else {
 alignerRunning = false;
 if (startOver) {
 startOver = false;
 setTimeout(setLineNumberHeights, 500);
 }
 }
 }
 function initLineNumberHeights() {
 // Do 2 complete passes, because there can be races
 // between this code and prettify.
 startOver = true;
 setTimeout(setLineNumberHeights, 250);
 window.onresize = setLineNumberHeights;
 }
 initLineNumberHeights();
</script>

 
 
 <div id="log">
 <div style="text-align:right">
 <a class="ifCollapse" href="#" onclick="_toggleMeta(this); return false">Show details</a>
 <a class="ifExpand" href="#" onclick="_toggleMeta(this); return false">Hide details</a>
 </div>
 <div class="ifExpand">
 
 
 <div class="pmeta_bubble_bg" style="border:1px solid white">
 <div class="round4"></div>
 <div class="round2"></div>
 <div class="round1"></div>
 <div class="box-inner">
 <div id="changelog">
 <p>Change log</p>
 <div>
 <a href="/p/baphy/source/detail?spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c&amp;r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3">5f8ae5ec007e</a>
 by Stephen David &lt;davids@ohsu.edu&gt;
 on May 21, 2014
 &nbsp; <a href="/p/baphy/source/diff?spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c&r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&amp;format=side&amp;path=/Config/lbhb/TrialObjects/%40RefTarOpt/ObjLoadSaveDefaults.m&amp;old_path=/Config/lbhb/TrialObjects/%40RefTarOpt/ObjLoadSaveDefaults.m&amp;old=">Diff</a>
 </div>
 <pre>Starting to add optical stimulus channel
option.
\
</pre>
 </div>
 
 
 
 
 
 
 <script type="text/javascript">
 var detail_url = '/p/baphy/source/detail?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c';
 var publish_url = '/p/baphy/source/detail?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c#publish';
 // describe the paths of this revision in javascript.
 var changed_paths = [];
 var changed_urls = [];
 
 changed_paths.push('/Config/lbhb/BaphyMainGuiItems.m');
 changed_urls.push('/p/baphy/source/browse/Config/lbhb/BaphyMainGuiItems.m?r\x3d5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 changed_paths.push('/Config/lbhb/InitializeHW.m');
 changed_urls.push('/p/baphy/source/browse/Config/lbhb/InitializeHW.m?r\x3d5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 changed_paths.push('/Config/lbhb/TrialObjects/@RefTarOpt/ObjLoadSaveDefaults.m');
 changed_urls.push('/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/ObjLoadSaveDefaults.m?r\x3d5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 var selected_path = '/Config/lbhb/TrialObjects/@RefTarOpt/ObjLoadSaveDefaults.m';
 
 
 changed_paths.push('/Config/lbhb/TrialObjects/@RefTarOpt/ObjUpdate.m');
 changed_urls.push('/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/ObjUpdate.m?r\x3d5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 changed_paths.push('/Config/lbhb/TrialObjects/@RefTarOpt/RandomizeSequence.m');
 changed_urls.push('/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/RandomizeSequence.m?r\x3d5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 changed_paths.push('/Config/lbhb/TrialObjects/@RefTarOpt/RefTarOpt.m');
 changed_urls.push('/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/RefTarOpt.m?r\x3d5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 changed_paths.push('/Config/lbhb/TrialObjects/@RefTarOpt/get.m');
 changed_urls.push('/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/get.m?r\x3d5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 changed_paths.push('/Config/lbhb/TrialObjects/@RefTarOpt/set.m');
 changed_urls.push('/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/set.m?r\x3d5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 changed_paths.push('/Config/lbhb/TrialObjects/@RefTarOpt/waveform.m');
 changed_urls.push('/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/waveform.m?r\x3d5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 changed_paths.push('/Hardware/IOLoadSound.m');
 changed_urls.push('/p/baphy/source/browse/Hardware/IOLoadSound.m?r\x3d5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 changed_paths.push('/Meska/m_mespca.m');
 changed_urls.push('/p/baphy/source/browse/Meska/m_mespca.m?r\x3d5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 changed_paths.push('/Utilities/cacheevpspikes.m');
 changed_urls.push('/p/baphy/source/browse/Utilities/cacheevpspikes.m?r\x3d5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 changed_paths.push('/cellDB/dbManualAddRaw.m');
 changed_urls.push('/p/baphy/source/browse/cellDB/dbManualAddRaw.m?r\x3d5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 function getCurrentPageIndex() {
 for (var i = 0; i < changed_paths.length; i++) {
 if (selected_path == changed_paths[i]) {
 return i;
 }
 }
 }
 function getNextPage() {
 var i = getCurrentPageIndex();
 if (i < changed_paths.length - 1) {
 return changed_urls[i + 1];
 }
 return null;
 }
 function getPreviousPage() {
 var i = getCurrentPageIndex();
 if (i > 0) {
 return changed_urls[i - 1];
 }
 return null;
 }
 function gotoNextPage() {
 var page = getNextPage();
 if (!page) {
 page = detail_url;
 }
 window.location = page;
 }
 function gotoPreviousPage() {
 var page = getPreviousPage();
 if (!page) {
 page = detail_url;
 }
 window.location = page;
 }
 function gotoDetailPage() {
 window.location = detail_url;
 }
 function gotoPublishPage() {
 window.location = publish_url;
 }
</script>

 
 <style type="text/css">
 #review_nav {
 border-top: 3px solid white;
 padding-top: 6px;
 margin-top: 1em;
 }
 #review_nav td {
 vertical-align: middle;
 }
 #review_nav select {
 margin: .5em 0;
 }
 </style>
 <div id="review_nav">
 <table><tr><td>Go to:&nbsp;</td><td>
 <select name="files_in_rev" onchange="window.location=this.value">
 
 <option value="/p/baphy/source/browse/Config/lbhb/BaphyMainGuiItems.m?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >/Config/lbhb/BaphyMainGuiItems.m</option>
 
 <option value="/p/baphy/source/browse/Config/lbhb/InitializeHW.m?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >/Config/lbhb/InitializeHW.m</option>
 
 <option value="/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/ObjLoadSaveDefaults.m?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 selected="selected"
 >...@RefTarOpt/ObjLoadSaveDefaults.m</option>
 
 <option value="/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/ObjUpdate.m?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >...alObjects/@RefTarOpt/ObjUpdate.m</option>
 
 <option value="/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/RandomizeSequence.m?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >...s/@RefTarOpt/RandomizeSequence.m</option>
 
 <option value="/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/RefTarOpt.m?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >...alObjects/@RefTarOpt/RefTarOpt.m</option>
 
 <option value="/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/get.m?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >...hb/TrialObjects/@RefTarOpt/get.m</option>
 
 <option value="/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/set.m?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >...hb/TrialObjects/@RefTarOpt/set.m</option>
 
 <option value="/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/waveform.m?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >...ialObjects/@RefTarOpt/waveform.m</option>
 
 <option value="/p/baphy/source/browse/Hardware/IOLoadSound.m?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >/Hardware/IOLoadSound.m</option>
 
 <option value="/p/baphy/source/browse/Meska/m_mespca.m?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >/Meska/m_mespca.m</option>
 
 <option value="/p/baphy/source/browse/Utilities/cacheevpspikes.m?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >/Utilities/cacheevpspikes.m</option>
 
 <option value="/p/baphy/source/browse/cellDB/dbManualAddRaw.m?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >/cellDB/dbManualAddRaw.m</option>
 
 </select>
 </td></tr></table>
 
 
 <div id="review_instr" class="closed">
 <a class="ifOpened" href="/p/baphy/source/detail?r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c#publish">Publish your comments</a>
 <div class="ifClosed">Double click a line to add a comment</div>
 </div>
 
 </div>
 
 
 </div>
 <div class="round1"></div>
 <div class="round2"></div>
 <div class="round4"></div>
 </div>
 <div class="pmeta_bubble_bg" style="border:1px solid white">
 <div class="round4"></div>
 <div class="round2"></div>
 <div class="round1"></div>
 <div class="box-inner">
 <div id="older_bubble">
 <p>Older revisions</p>
 
 <a href="/p/baphy/source/list?path=/Config/lbhb/TrialObjects/%40RefTarOpt/ObjLoadSaveDefaults.m&r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3">All revisions of this file</a>
 </div>
 </div>
 <div class="round1"></div>
 <div class="round2"></div>
 <div class="round4"></div>
 </div>
 
 <div class="pmeta_bubble_bg" style="border:1px solid white">
 <div class="round4"></div>
 <div class="round2"></div>
 <div class="round1"></div>
 <div class="box-inner">
 <div id="fileinfo_bubble">
 <p>File info</p>
 
 <div>Size: 1901 bytes,
 53 lines</div>
 
 <div><a href="//baphy.googlecode.com/git/Config/lbhb/TrialObjects/@RefTarOpt/ObjLoadSaveDefaults.m">View raw file</a></div>
 </div>
 
 </div>
 <div class="round1"></div>
 <div class="round2"></div>
 <div class="round4"></div>
 </div>
 </div>
 </div>


</div>

</div>
</div>

<script src="https://ssl.gstatic.com/codesite/ph/17097911804237236952/js/prettify/prettify.js"></script>
<script type="text/javascript">prettyPrint();</script>


<script src="https://ssl.gstatic.com/codesite/ph/17097911804237236952/js/source_file_scripts.js"></script>

 <script type="text/javascript" src="https://ssl.gstatic.com/codesite/ph/17097911804237236952/js/kibbles.js"></script>
 <script type="text/javascript">
 var lastStop = null;
 var initialized = false;
 
 function updateCursor(next, prev) {
 if (prev && prev.element) {
 prev.element.className = 'cursor_stop cursor_hidden';
 }
 if (next && next.element) {
 next.element.className = 'cursor_stop cursor';
 lastStop = next.index;
 }
 }
 
 function pubRevealed(data) {
 updateCursorForCell(data.cellId, 'cursor_stop cursor_hidden');
 if (initialized) {
 reloadCursors();
 }
 }
 
 function draftRevealed(data) {
 updateCursorForCell(data.cellId, 'cursor_stop cursor_hidden');
 if (initialized) {
 reloadCursors();
 }
 }
 
 function draftDestroyed(data) {
 updateCursorForCell(data.cellId, 'nocursor');
 if (initialized) {
 reloadCursors();
 }
 }
 function reloadCursors() {
 kibbles.skipper.reset();
 loadCursors();
 if (lastStop != null) {
 kibbles.skipper.setCurrentStop(lastStop);
 }
 }
 // possibly the simplest way to insert any newly added comments
 // is to update the class of the corresponding cursor row,
 // then refresh the entire list of rows.
 function updateCursorForCell(cellId, className) {
 var cell = document.getElementById(cellId);
 // we have to go two rows back to find the cursor location
 var row = getPreviousElement(cell.parentNode);
 row.className = className;
 }
 // returns the previous element, ignores text nodes.
 function getPreviousElement(e) {
 var element = e.previousSibling;
 if (element.nodeType == 3) {
 element = element.previousSibling;
 }
 if (element && element.tagName) {
 return element;
 }
 }
 function loadCursors() {
 // register our elements with skipper
 var elements = CR_getElements('*', 'cursor_stop');
 var len = elements.length;
 for (var i = 0; i < len; i++) {
 var element = elements[i]; 
 element.className = 'cursor_stop cursor_hidden';
 kibbles.skipper.append(element);
 }
 }
 function toggleComments() {
 CR_toggleCommentDisplay();
 reloadCursors();
 }
 function keysOnLoadHandler() {
 // setup skipper
 kibbles.skipper.addStopListener(
 kibbles.skipper.LISTENER_TYPE.PRE, updateCursor);
 // Set the 'offset' option to return the middle of the client area
 // an option can be a static value, or a callback
 kibbles.skipper.setOption('padding_top', 50);
 // Set the 'offset' option to return the middle of the client area
 // an option can be a static value, or a callback
 kibbles.skipper.setOption('padding_bottom', 100);
 // Register our keys
 kibbles.skipper.addFwdKey("n");
 kibbles.skipper.addRevKey("p");
 kibbles.keys.addKeyPressListener(
 'u', function() { window.location = detail_url; });
 kibbles.keys.addKeyPressListener(
 'r', function() { window.location = detail_url + '#publish'; });
 
 kibbles.keys.addKeyPressListener('j', gotoNextPage);
 kibbles.keys.addKeyPressListener('k', gotoPreviousPage);
 
 
 kibbles.keys.addKeyPressListener('h', toggleComments);
 
 }
 </script>
<script src="https://ssl.gstatic.com/codesite/ph/17097911804237236952/js/code_review_scripts.js"></script>
<script type="text/javascript">
 function showPublishInstructions() {
 var element = document.getElementById('review_instr');
 if (element) {
 element.className = 'opened';
 }
 }
 var codereviews;
 function revsOnLoadHandler() {
 // register our source container with the commenting code
 var paths = {'svne8a83f1978e8252fc8f4030b6d6a882f0e87739c': '/Config/lbhb/TrialObjects/@RefTarOpt/ObjLoadSaveDefaults.m'}
 codereviews = CR_controller.setup(
 {"token": "ABZ6GAeC5X_a7K1BFjPgTkyfTKi2mFfewQ:1410858437809", "profileUrl": "/u/105489876805901808296/", "projectName": "baphy", "assetHostPath": "https://ssl.gstatic.com/codesite/ph", "domainName": null, "projectHomeUrl": "/p/baphy", "assetVersionPath": "https://ssl.gstatic.com/codesite/ph/17097911804237236952", "loggedInUserEmail": "boubenec@gmail.com", "relativeBaseUrl": ""}, '', 'svne8a83f1978e8252fc8f4030b6d6a882f0e87739c', paths,
 CR_BrowseIntegrationFactory);
 
 // register our source container with the commenting code
 // in this case we're registering the container and the revison
 // associated with the contianer which may be the primary revision
 // or may be a previous revision against which the primary revision
 // of the file is being compared.
 codereviews.registerSourceContainer(document.getElementById('lines'), 'svne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 codereviews.registerActivityListener(CR_ActivityType.REVEAL_DRAFT_PLATE, showPublishInstructions);
 
 codereviews.registerActivityListener(CR_ActivityType.REVEAL_PUB_PLATE, pubRevealed);
 codereviews.registerActivityListener(CR_ActivityType.REVEAL_DRAFT_PLATE, draftRevealed);
 codereviews.registerActivityListener(CR_ActivityType.DISCARD_DRAFT_COMMENT, draftDestroyed);
 
 
 
 
 
 
 
 var initialized = true;
 reloadCursors();
 }
 window.onload = function() {keysOnLoadHandler(); revsOnLoadHandler();};

</script>
<script type="text/javascript" src="https://ssl.gstatic.com/codesite/ph/17097911804237236952/js/dit_scripts.js"></script>

 
 
 
 <script type="text/javascript" src="https://ssl.gstatic.com/codesite/ph/17097911804237236952/js/ph_core.js"></script>
 
 
 
 
</div> 

<div id="footer" dir="ltr">
 <div class="text">
 <a href="/projecthosting/terms.html">Terms</a> -
 <a href="http://www.google.com/privacy.html">Privacy</a> -
 <a href="/p/support/">Project Hosting Help</a>
 </div>
</div>
 <div class="hostedBy" style="margin-top: -20px;">
 <span style="vertical-align: top;">Powered by <a href="http://code.google.com/projecthosting/">Google Project Hosting</a></span>
 </div>

 
 


 
 </body>
</html>

