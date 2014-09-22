



<!DOCTYPE html>
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" >
 <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" >
 
 <meta name="ROBOTS" content="NOARCHIVE">
 
 <link rel="icon" type="image/vnd.microsoft.icon" href="https://ssl.gstatic.com/codesite/ph/images/phosting.ico">
 
 
 <script type="text/javascript">
 
 
 
 
 var codesite_token = "ABZ6GAcEsfN1y96Qt3jsv6K7oZN1VM6OQA:1410858462452";
 
 
 var CS_env = {"token": "ABZ6GAcEsfN1y96Qt3jsv6K7oZN1VM6OQA:1410858462452", "projectHomeUrl": "/p/baphy", "profileUrl": "/u/105489876805901808296/", "assetVersionPath": "https://ssl.gstatic.com/codesite/ph/17097911804237236952", "assetHostPath": "https://ssl.gstatic.com/codesite/ph", "domainName": null, "relativeBaseUrl": "", "projectName": "baphy", "loggedInUserEmail": "boubenec@gmail.com"};
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
 
 
 <title>RandomizeSequence.m - 
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
 | <a href="https://www.google.com/accounts/Logout?continue=https%3A%2F%2Fcode.google.com%2Fp%2Fbaphy%2Fsource%2Fbrowse%2FConfig%2Flbhb%2FTrialObjects%2F%40RefTarOpt%2FRandomizeSequence.m" 
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
 <span id="crumb_links" class="ifClosed"><a href="/p/baphy/source/browse/Config/">Config</a><span class="sp">/&nbsp;</span><a href="/p/baphy/source/browse/Config/lbhb/">lbhb</a><span class="sp">/&nbsp;</span><a href="/p/baphy/source/browse/Config/lbhb/TrialObjects/">TrialObjects</a><span class="sp">/&nbsp;</span><a href="/p/baphy/source/browse/Config/lbhb/TrialObjects/%40RefTarOpt/">@RefTarOpt</a><span class="sp">/&nbsp;</span>RandomizeSequence.m</span>
 
 
 
 
 
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
 <a href="/p/baphy/source/browse/Config/lbhb/TrialObjects/%40RefTarOpt/RandomizeSequence.m?edit=1"
 ><img src="https://ssl.gstatic.com/codesite/ph/images/pencil-y14.png"
 class="edit_icon">Edit file</a>
 </td>
 
 
 <td nowrap="nowrap" width="33%" align="right">
 <table cellpadding="0" cellspacing="0" style="font-size: 100%"><tr>
 
 
 <td class="flipper">
 <ul class="leftside">
 
 <li><a href="/p/baphy/source/browse/Config/lbhb/TrialObjects/%40RefTarOpt/RandomizeSequence.m?r=1100f69d18244524aa7c38269c9061b204b69844" title="Previous">&lsaquo;1100f69d1824</a></li>
 
 </ul>
 </td>
 
 <td class="flipper"><b>e8a83f1978e8</b></td>
 
 <td class="flipper">
 <ul class="rightside">
 
 <li><a href="/p/baphy/source/browse/Config/lbhb/TrialObjects/%40RefTarOpt/RandomizeSequence.m?r=df1ce621640fea56f24c26821121397f3c6a9c4c" title="Next">df1ce621640f&rsaquo;</a></li>
 
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
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_54"

 onmouseover="gutterOver(54)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',54);">&nbsp;</span
></td><td id="54"><a href="#54">54</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_55"

 onmouseover="gutterOver(55)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',55);">&nbsp;</span
></td><td id="55"><a href="#55">55</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_56"

 onmouseover="gutterOver(56)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',56);">&nbsp;</span
></td><td id="56"><a href="#56">56</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_57"

 onmouseover="gutterOver(57)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',57);">&nbsp;</span
></td><td id="57"><a href="#57">57</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_58"

 onmouseover="gutterOver(58)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',58);">&nbsp;</span
></td><td id="58"><a href="#58">58</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_59"

 onmouseover="gutterOver(59)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',59);">&nbsp;</span
></td><td id="59"><a href="#59">59</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_60"

 onmouseover="gutterOver(60)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',60);">&nbsp;</span
></td><td id="60"><a href="#60">60</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_61"

 onmouseover="gutterOver(61)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',61);">&nbsp;</span
></td><td id="61"><a href="#61">61</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_62"

 onmouseover="gutterOver(62)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',62);">&nbsp;</span
></td><td id="62"><a href="#62">62</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_63"

 onmouseover="gutterOver(63)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',63);">&nbsp;</span
></td><td id="63"><a href="#63">63</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_64"

 onmouseover="gutterOver(64)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',64);">&nbsp;</span
></td><td id="64"><a href="#64">64</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_65"

 onmouseover="gutterOver(65)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',65);">&nbsp;</span
></td><td id="65"><a href="#65">65</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_66"

 onmouseover="gutterOver(66)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',66);">&nbsp;</span
></td><td id="66"><a href="#66">66</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_67"

 onmouseover="gutterOver(67)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',67);">&nbsp;</span
></td><td id="67"><a href="#67">67</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_68"

 onmouseover="gutterOver(68)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',68);">&nbsp;</span
></td><td id="68"><a href="#68">68</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_69"

 onmouseover="gutterOver(69)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',69);">&nbsp;</span
></td><td id="69"><a href="#69">69</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_70"

 onmouseover="gutterOver(70)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',70);">&nbsp;</span
></td><td id="70"><a href="#70">70</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_71"

 onmouseover="gutterOver(71)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',71);">&nbsp;</span
></td><td id="71"><a href="#71">71</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_72"

 onmouseover="gutterOver(72)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',72);">&nbsp;</span
></td><td id="72"><a href="#72">72</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_73"

 onmouseover="gutterOver(73)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',73);">&nbsp;</span
></td><td id="73"><a href="#73">73</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_74"

 onmouseover="gutterOver(74)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',74);">&nbsp;</span
></td><td id="74"><a href="#74">74</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_75"

 onmouseover="gutterOver(75)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',75);">&nbsp;</span
></td><td id="75"><a href="#75">75</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_76"

 onmouseover="gutterOver(76)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',76);">&nbsp;</span
></td><td id="76"><a href="#76">76</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_77"

 onmouseover="gutterOver(77)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',77);">&nbsp;</span
></td><td id="77"><a href="#77">77</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_78"

 onmouseover="gutterOver(78)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',78);">&nbsp;</span
></td><td id="78"><a href="#78">78</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_79"

 onmouseover="gutterOver(79)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',79);">&nbsp;</span
></td><td id="79"><a href="#79">79</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_80"

 onmouseover="gutterOver(80)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',80);">&nbsp;</span
></td><td id="80"><a href="#80">80</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_81"

 onmouseover="gutterOver(81)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',81);">&nbsp;</span
></td><td id="81"><a href="#81">81</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_82"

 onmouseover="gutterOver(82)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',82);">&nbsp;</span
></td><td id="82"><a href="#82">82</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_83"

 onmouseover="gutterOver(83)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',83);">&nbsp;</span
></td><td id="83"><a href="#83">83</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_84"

 onmouseover="gutterOver(84)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',84);">&nbsp;</span
></td><td id="84"><a href="#84">84</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_85"

 onmouseover="gutterOver(85)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',85);">&nbsp;</span
></td><td id="85"><a href="#85">85</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_86"

 onmouseover="gutterOver(86)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',86);">&nbsp;</span
></td><td id="86"><a href="#86">86</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_87"

 onmouseover="gutterOver(87)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',87);">&nbsp;</span
></td><td id="87"><a href="#87">87</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_88"

 onmouseover="gutterOver(88)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',88);">&nbsp;</span
></td><td id="88"><a href="#88">88</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_89"

 onmouseover="gutterOver(89)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',89);">&nbsp;</span
></td><td id="89"><a href="#89">89</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_90"

 onmouseover="gutterOver(90)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',90);">&nbsp;</span
></td><td id="90"><a href="#90">90</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_91"

 onmouseover="gutterOver(91)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',91);">&nbsp;</span
></td><td id="91"><a href="#91">91</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_92"

 onmouseover="gutterOver(92)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',92);">&nbsp;</span
></td><td id="92"><a href="#92">92</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_93"

 onmouseover="gutterOver(93)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',93);">&nbsp;</span
></td><td id="93"><a href="#93">93</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_94"

 onmouseover="gutterOver(94)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',94);">&nbsp;</span
></td><td id="94"><a href="#94">94</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_95"

 onmouseover="gutterOver(95)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',95);">&nbsp;</span
></td><td id="95"><a href="#95">95</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_96"

 onmouseover="gutterOver(96)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',96);">&nbsp;</span
></td><td id="96"><a href="#96">96</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_97"

 onmouseover="gutterOver(97)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',97);">&nbsp;</span
></td><td id="97"><a href="#97">97</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_98"

 onmouseover="gutterOver(98)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',98);">&nbsp;</span
></td><td id="98"><a href="#98">98</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_99"

 onmouseover="gutterOver(99)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',99);">&nbsp;</span
></td><td id="99"><a href="#99">99</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_100"

 onmouseover="gutterOver(100)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',100);">&nbsp;</span
></td><td id="100"><a href="#100">100</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_101"

 onmouseover="gutterOver(101)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',101);">&nbsp;</span
></td><td id="101"><a href="#101">101</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_102"

 onmouseover="gutterOver(102)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',102);">&nbsp;</span
></td><td id="102"><a href="#102">102</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_103"

 onmouseover="gutterOver(103)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',103);">&nbsp;</span
></td><td id="103"><a href="#103">103</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_104"

 onmouseover="gutterOver(104)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',104);">&nbsp;</span
></td><td id="104"><a href="#104">104</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_105"

 onmouseover="gutterOver(105)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',105);">&nbsp;</span
></td><td id="105"><a href="#105">105</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_106"

 onmouseover="gutterOver(106)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',106);">&nbsp;</span
></td><td id="106"><a href="#106">106</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_107"

 onmouseover="gutterOver(107)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',107);">&nbsp;</span
></td><td id="107"><a href="#107">107</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_108"

 onmouseover="gutterOver(108)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',108);">&nbsp;</span
></td><td id="108"><a href="#108">108</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_109"

 onmouseover="gutterOver(109)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',109);">&nbsp;</span
></td><td id="109"><a href="#109">109</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_110"

 onmouseover="gutterOver(110)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',110);">&nbsp;</span
></td><td id="110"><a href="#110">110</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_111"

 onmouseover="gutterOver(111)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',111);">&nbsp;</span
></td><td id="111"><a href="#111">111</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_112"

 onmouseover="gutterOver(112)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',112);">&nbsp;</span
></td><td id="112"><a href="#112">112</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_113"

 onmouseover="gutterOver(113)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',113);">&nbsp;</span
></td><td id="113"><a href="#113">113</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_114"

 onmouseover="gutterOver(114)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',114);">&nbsp;</span
></td><td id="114"><a href="#114">114</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_115"

 onmouseover="gutterOver(115)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',115);">&nbsp;</span
></td><td id="115"><a href="#115">115</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_116"

 onmouseover="gutterOver(116)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',116);">&nbsp;</span
></td><td id="116"><a href="#116">116</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_117"

 onmouseover="gutterOver(117)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',117);">&nbsp;</span
></td><td id="117"><a href="#117">117</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_118"

 onmouseover="gutterOver(118)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',118);">&nbsp;</span
></td><td id="118"><a href="#118">118</a></td></tr
><tr id="gr_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_119"

 onmouseover="gutterOver(119)"

><td><span title="Add comment" onclick="codereviews.startEdit('svne8a83f1978e8252fc8f4030b6d6a882f0e87739c',119);">&nbsp;</span
></td><td id="119"><a href="#119">119</a></td></tr
></table></pre>
<pre><table width="100%"><tr class="nocursor"><td></td></tr></table></pre>
</td>
<td id="lines">
<pre><table width="100%"><tr class="cursor_stop cursor_hidden"><td></td></tr></table></pre>
<pre class="prettyprint lang-m"><table id="src_table_0"><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_1

 onmouseover="gutterOver(1)"

><td class="source">function [exptparams] = RandomizeSequence (o, exptparams, globalparams, RepIndex, RepOrTrial)<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_2

 onmouseover="gutterOver(2)"

><td class="source">% Function Trial Sequence is one of the methods of class ReferenceTarget<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_3

 onmouseover="gutterOver(3)"

><td class="source">% This function is responsible for producing the random sequence of<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_4

 onmouseover="gutterOver(4)"

><td class="source">% references, targets, trials and etc. <br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_5

 onmouseover="gutterOver(5)"

><td class="source"><br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_6

 onmouseover="gutterOver(6)"

><td class="source">% Nima Mesgarani, October 2005<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_7

 onmouseover="gutterOver(7)"

><td class="source">if nargin&lt;4, RepOrTrial = 0;end   % default is its a trial call<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_8

 onmouseover="gutterOver(8)"

><td class="source">if nargin&lt;3, RepIndex = 1;end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_9

 onmouseover="gutterOver(9)"

><td class="source">% ReferenceTarget is not an adaptive learning, so we don&#39;t change anything<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_10

 onmouseover="gutterOver(10)"

><td class="source">% for each trial, we do it once for the entire repetition. So, if its<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_11

 onmouseover="gutterOver(11)"

><td class="source">% trial, return:<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_12

 onmouseover="gutterOver(12)"

><td class="source">if RepOrTrial == 0, return; end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_13

 onmouseover="gutterOver(13)"

><td class="source">% read the trial parameters<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_14

 onmouseover="gutterOver(14)"

><td class="source">par = get(o);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_15

 onmouseover="gutterOver(15)"

><td class="source"><br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_16

 onmouseover="gutterOver(16)"

><td class="source">NumRef = par.NumberOfRefPerTrial(:);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_17

 onmouseover="gutterOver(17)"

><td class="source">IsLookup = isempty(NumRef) | ~isnumeric(NumRef);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_18

 onmouseover="gutterOver(18)"

><td class="source">% for now, lets assume Lookup table:<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_19

 onmouseover="gutterOver(19)"

><td class="source">IsLookUp = 1;<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_20

 onmouseover="gutterOver(20)"

><td class="source">%<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_21

 onmouseover="gutterOver(21)"

><td class="source">if IsLookup<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_22

 onmouseover="gutterOver(22)"

><td class="source">    if strcmpi(par.TargetClass,&#39;none&#39;),<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_23

 onmouseover="gutterOver(23)"

><td class="source">        tr=get(get(exptparams.TrialObject,&#39;ReferenceHandle&#39;));<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_24

 onmouseover="gutterOver(24)"

><td class="source">        if isfield(tr,&#39;RefRepCount&#39;),<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_25

 onmouseover="gutterOver(25)"

><td class="source">            NumRef=tr.RefRepCount;<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_26

 onmouseover="gutterOver(26)"

><td class="source">        else<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_27

 onmouseover="gutterOver(27)"

><td class="source">            NumRef=1;<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_28

 onmouseover="gutterOver(28)"

><td class="source">        end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_29

 onmouseover="gutterOver(29)"

><td class="source">    else<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_30

 onmouseover="gutterOver(30)"

><td class="source">        LookupTable = [3 4 7 3 2 7 3 1 4 1 5 7 2 1 6 4 7 2 1 7 2 5 1 3 2 1 7 4 7 5 6];<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_31

 onmouseover="gutterOver(31)"

><td class="source">        tt = what(class(o));<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_32

 onmouseover="gutterOver(32)"

><td class="source">        LookupFile = [tt.path filesep &#39;LastLookup.mat&#39;]<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_33

 onmouseover="gutterOver(33)"

><td class="source">        if exist(LookupFile,&#39;file&#39;)      load (LookupFile);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_34

 onmouseover="gutterOver(34)"

><td class="source">        else             LastLookup = 1;<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_35

 onmouseover="gutterOver(35)"

><td class="source">        end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_36

 onmouseover="gutterOver(36)"

><td class="source">        NumRef = circshift(LookupTable(:), LastLookup);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_37

 onmouseover="gutterOver(37)"

><td class="source">    end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_38

 onmouseover="gutterOver(38)"

><td class="source">end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_39

 onmouseover="gutterOver(39)"

><td class="source">temp = [];<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_40

 onmouseover="gutterOver(40)"

><td class="source">ReferenceMaxIndex = par.ReferenceMaxIndex ;<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_41

 onmouseover="gutterOver(41)"

><td class="source">% here, we try to specify the real number of references per trial, and<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_42

 onmouseover="gutterOver(42)"

><td class="source">% determine how many trials are needed to cover all the references. If its<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_43

 onmouseover="gutterOver(43)"

><td class="source">% a detect case, its easy. Add from NumRef to trials until the sum of<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_44

 onmouseover="gutterOver(44)"

><td class="source">% references becomes equal to maxindex. <br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_45

 onmouseover="gutterOver(45)"

><td class="source">% in discrim, if its not sham, the number of references per trial is added<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_46

 onmouseover="gutterOver(46)"

><td class="source">% by one because one reference goes into target.<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_47

 onmouseover="gutterOver(47)"

><td class="source">while sum(temp) &lt; ReferenceMaxIndex      % while not all the references are covered<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_48

 onmouseover="gutterOver(48)"

><td class="source">    if isempty(NumRef)  % if not and if NumRef is empty just finish it<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_49

 onmouseover="gutterOver(49)"

><td class="source">        temp = [temp ReferenceMaxIndex-sum(temp)]; % temp holds the number of references in each trial<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_50

 onmouseover="gutterOver(50)"

><td class="source">%     elseif sum(temp)+NumRef(1)+(IsDiscrim &amp; ~IsSham(1)) &lt;= ReferenceMaxIndex % can we add NumRef(1)?<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_51

 onmouseover="gutterOver(51)"

><td class="source">    elseif sum(temp)+NumRef(1) &lt;= ReferenceMaxIndex % can we add NumRef(1)?<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_52

 onmouseover="gutterOver(52)"

><td class="source">        temp = [temp NumRef(1)]; % if so, add it and circle NumRef<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_53

 onmouseover="gutterOver(53)"

><td class="source">        NumRef = circshift (NumRef, -1);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_54

 onmouseover="gutterOver(54)"

><td class="source">    else<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_55

 onmouseover="gutterOver(55)"

><td class="source">        NumRef(1)=[]; % otherwise remove this number from NumRef<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_56

 onmouseover="gutterOver(56)"

><td class="source">    end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_57

 onmouseover="gutterOver(57)"

><td class="source">end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_58

 onmouseover="gutterOver(58)"

><td class="source">if ~IsLookup  % if its a lookup table, dont randomize, if not randomize them<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_59

 onmouseover="gutterOver(59)"

><td class="source">    RefNumTemp = temp(randperm(length(temp))); % randomized number of references in each trial<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_60

 onmouseover="gutterOver(60)"

><td class="source">else<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_61

 onmouseover="gutterOver(61)"

><td class="source">    RefNumTemp = temp;<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_62

 onmouseover="gutterOver(62)"

><td class="source">end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_63

 onmouseover="gutterOver(63)"

><td class="source">% Lets specify which trials are sham:<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_64

 onmouseover="gutterOver(64)"

><td class="source">TotalTrials = length(RefNumTemp);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_65

 onmouseover="gutterOver(65)"

><td class="source">if (get(o,&#39;NumberOfTarPerTrial&#39;) ~= 0) &amp;&amp; (~strcmpi(get(o,&#39;TargetClass&#39;),&#39;None&#39;)) <br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_66

 onmouseover="gutterOver(66)"

><td class="source">    if ~IsLookup<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_67

 onmouseover="gutterOver(67)"

><td class="source">        NotShamNumber = floor((100-par.ShamPercentage) * TotalTrials / 100); % how many shams do we have??<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_68

 onmouseover="gutterOver(68)"

><td class="source">        allTrials  = randperm(TotalTrials); %<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_69

 onmouseover="gutterOver(69)"

><td class="source">        NotShamTrials = allTrials (1:NotShamNumber);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_70

 onmouseover="gutterOver(70)"

><td class="source">    else<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_71

 onmouseover="gutterOver(71)"

><td class="source">        NotShamTrials = find(RefNumTemp &lt; max(LookupTable));<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_72

 onmouseover="gutterOver(72)"

><td class="source">    end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_73

 onmouseover="gutterOver(73)"

><td class="source">    TargetIndex = cell(1,length(RefNumTemp));<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_74

 onmouseover="gutterOver(74)"

><td class="source">    for cnt1=1:length(NotShamTrials)<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_75

 onmouseover="gutterOver(75)"

><td class="source">        TargetIndex{NotShamTrials(cnt1)} = 1+floor(rand(1)*par.TargetMaxIndex);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_76

 onmouseover="gutterOver(76)"

><td class="source">    end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_77

 onmouseover="gutterOver(77)"

><td class="source">else<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_78

 onmouseover="gutterOver(78)"

><td class="source">    TargetIndex = [];<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_79

 onmouseover="gutterOver(79)"

><td class="source">end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_80

 onmouseover="gutterOver(80)"

><td class="source">% at this point, we know how many references in each trial we have. If its<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_81

 onmouseover="gutterOver(81)"

><td class="source">% a detect case, we just need to choose randomly from references and put<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_82

 onmouseover="gutterOver(82)"

><td class="source">% them in the trial. But in discrim case, we put one index in the target<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_83

 onmouseover="gutterOver(83)"

><td class="source">% also, if its not a sham. <br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_84

 onmouseover="gutterOver(84)"

><td class="source">% Now generate random sequences for each trial<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_85

 onmouseover="gutterOver(85)"

><td class="source">RandIndex = randperm(par.ReferenceMaxIndex);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_86

 onmouseover="gutterOver(86)"

><td class="source">RefTrialIndex=cell(1,length(RefNumTemp));<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_87

 onmouseover="gutterOver(87)"

><td class="source">for cnt1=1:length(RefNumTemp)<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_88

 onmouseover="gutterOver(88)"

><td class="source">    RefTrialIndex {cnt1} = RandIndex (1:RefNumTemp(cnt1));<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_89

 onmouseover="gutterOver(89)"

><td class="source">    RandIndex (1:RefNumTemp(cnt1)) = [];<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_90

 onmouseover="gutterOver(90)"

><td class="source">end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_91

 onmouseover="gutterOver(91)"

><td class="source"><br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_92

 onmouseover="gutterOver(92)"

><td class="source">% Inserting new stuff for Optical channel.  Double the number of trials.<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_93

 onmouseover="gutterOver(93)"

><td class="source">%<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_94

 onmouseover="gutterOver(94)"

><td class="source">LightTrial=[zeros(1,TotalTrials) ones(1,TotalTrials)];<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_95

 onmouseover="gutterOver(95)"

><td class="source">RefTrialIndex=cat(2,RefTrialIndex,RefTrialIndex);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_96

 onmouseover="gutterOver(96)"

><td class="source">TotalTrials=TotalTrials*2;<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_97

 onmouseover="gutterOver(97)"

><td class="source"><br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_98

 onmouseover="gutterOver(98)"

><td class="source">[~,si]=sort(rand(1,TotalTrials));<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_99

 onmouseover="gutterOver(99)"

><td class="source">LightTrial=LightTrial(si);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_100

 onmouseover="gutterOver(100)"

><td class="source">RefTrialIndex=RefTrialIndex(si);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_101

 onmouseover="gutterOver(101)"

><td class="source">if ~isempty(TargetIndex),<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_102

 onmouseover="gutterOver(102)"

><td class="source">    TargetIndex=cat(2,TargetIndex,TargetIndex);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_103

 onmouseover="gutterOver(103)"

><td class="source">    TargetIndex=TargetIndex(si);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_104

 onmouseover="gutterOver(104)"

><td class="source">end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_105

 onmouseover="gutterOver(105)"

><td class="source"><br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_106

 onmouseover="gutterOver(106)"

><td class="source">o = set(o,&#39;LightTrial&#39;,LightTrial);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_107

 onmouseover="gutterOver(107)"

><td class="source">o = set(o,&#39;ReferenceIndices&#39;,RefTrialIndex);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_108

 onmouseover="gutterOver(108)"

><td class="source">o = set(o,&#39;TargetIndices&#39;,TargetIndex);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_109

 onmouseover="gutterOver(109)"

><td class="source">o = set(o,&#39;NumberOfTrials&#39;,TotalTrials);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_110

 onmouseover="gutterOver(110)"

><td class="source">% the following line eliminates the first prestim silence.<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_111

 onmouseover="gutterOver(111)"

><td class="source">% if get(exptparams.BehaveObject,&#39;ExtendedShock&#39;)<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_112

 onmouseover="gutterOver(112)"

><td class="source">%     o = set(o,&#39;NoPreStimForFirstRef&#39;,1);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_113

 onmouseover="gutterOver(113)"

><td class="source">% end<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_114

 onmouseover="gutterOver(114)"

><td class="source">exptparams.TrialObject = o;<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_115

 onmouseover="gutterOver(115)"

><td class="source">if exist(&#39;LastLookup&#39;,&#39;var&#39;)<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_116

 onmouseover="gutterOver(116)"

><td class="source">    LastLookup = LastLookup+TotalTrials;<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_117

 onmouseover="gutterOver(117)"

><td class="source">    tt = what(class(o));<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_118

 onmouseover="gutterOver(118)"

><td class="source">    save ([tt.path filesep &#39;LastLookup.mat&#39;],&#39;LastLookup&#39;);<br></td></tr
><tr
id=sl_svne8a83f1978e8252fc8f4030b6d6a882f0e87739c_119

 onmouseover="gutterOver(119)"

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
 <a href="/p/baphy/source/detail?spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c&amp;r=df1ce621640fea56f24c26821121397f3c6a9c4c">df1ce621640f</a>
 by Stephen David &lt;stephen.v.david@gmail.com&gt;
 on Jun 27, 2014
 &nbsp; <a href="/p/baphy/source/diff?spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c&r=df1ce621640fea56f24c26821121397f3c6a9c4c&amp;format=side&amp;path=/Config/lbhb/TrialObjects/%40RefTarOpt/RandomizeSequence.m&amp;old_path=/Config/lbhb/TrialObjects/%40RefTarOpt/RandomizeSequence.m&amp;old=1100f69d18244524aa7c38269c9061b204b69844">Diff</a>
 </div>
 <pre>Added optogenetics rig for LBHB, some
extra support for photostim control.
</pre>
 </div>
 
 
 
 
 
 
 <script type="text/javascript">
 var detail_url = '/p/baphy/source/detail?r=df1ce621640fea56f24c26821121397f3c6a9c4c&spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c';
 var publish_url = '/p/baphy/source/detail?r=df1ce621640fea56f24c26821121397f3c6a9c4c&spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c#publish';
 // describe the paths of this revision in javascript.
 var changed_paths = [];
 var changed_urls = [];
 
 changed_paths.push('/Config/lbhb/BaphyMainGuiItems.m');
 changed_urls.push('/p/baphy/source/browse/Config/lbhb/BaphyMainGuiItems.m?r\x3ddf1ce621640fea56f24c26821121397f3c6a9c4c\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 changed_paths.push('/Config/lbhb/TrialObjects/@RefTarOpt/RandomizeSequence.m');
 changed_urls.push('/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/RandomizeSequence.m?r\x3ddf1ce621640fea56f24c26821121397f3c6a9c4c\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 var selected_path = '/Config/lbhb/TrialObjects/@RefTarOpt/RandomizeSequence.m';
 
 
 changed_paths.push('/Config/lbhb/TrialObjects/@RefTarOpt/RefTarOpt.m');
 changed_urls.push('/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/RefTarOpt.m?r\x3ddf1ce621640fea56f24c26821121397f3c6a9c4c\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 changed_paths.push('/Config/lbhb/TrialObjects/@RefTarOpt/waveform.m');
 changed_urls.push('/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/waveform.m?r\x3ddf1ce621640fea56f24c26821121397f3c6a9c4c\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 changed_paths.push('/Modules/RefTar/BehaviorObjects/@PunishTarget/LastValues.mat');
 changed_urls.push('/p/baphy/source/browse/Modules/RefTar/BehaviorObjects/@PunishTarget/LastValues.mat?r\x3ddf1ce621640fea56f24c26821121397f3c6a9c4c\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
 changed_paths.push('/SoundObjects/@Silence/Silence.m');
 changed_urls.push('/p/baphy/source/browse/SoundObjects/@Silence/Silence.m?r\x3ddf1ce621640fea56f24c26821121397f3c6a9c4c\x26spec\x3dsvne8a83f1978e8252fc8f4030b6d6a882f0e87739c');
 
 
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
 
 <option value="/p/baphy/source/browse/Config/lbhb/BaphyMainGuiItems.m?r=df1ce621640fea56f24c26821121397f3c6a9c4c&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >/Config/lbhb/BaphyMainGuiItems.m</option>
 
 <option value="/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/RandomizeSequence.m?r=df1ce621640fea56f24c26821121397f3c6a9c4c&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 selected="selected"
 >...s/@RefTarOpt/RandomizeSequence.m</option>
 
 <option value="/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/RefTarOpt.m?r=df1ce621640fea56f24c26821121397f3c6a9c4c&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >...alObjects/@RefTarOpt/RefTarOpt.m</option>
 
 <option value="/p/baphy/source/browse/Config/lbhb/TrialObjects/@RefTarOpt/waveform.m?r=df1ce621640fea56f24c26821121397f3c6a9c4c&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >...ialObjects/@RefTarOpt/waveform.m</option>
 
 <option value="/p/baphy/source/browse/Modules/RefTar/BehaviorObjects/@PunishTarget/LastValues.mat?r=df1ce621640fea56f24c26821121397f3c6a9c4c&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >...cts/@PunishTarget/LastValues.mat</option>
 
 <option value="/p/baphy/source/browse/SoundObjects/@Silence/Silence.m?r=df1ce621640fea56f24c26821121397f3c6a9c4c&amp;spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c"
 
 >/SoundObjects/@Silence/Silence.m</option>
 
 </select>
 </td></tr></table>
 
 
 <div id="review_instr" class="closed">
 <a class="ifOpened" href="/p/baphy/source/detail?r=df1ce621640fea56f24c26821121397f3c6a9c4c&spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c#publish">Publish your comments</a>
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
 
 
 <div class="closed" style="margin-bottom:3px;" >
 <a class="ifClosed" onclick="return _toggleHidden(this)"><img src="https://ssl.gstatic.com/codesite/ph/images/plus.gif" ></a>
 <a class="ifOpened" onclick="return _toggleHidden(this)"><img src="https://ssl.gstatic.com/codesite/ph/images/minus.gif" ></a>
 <a href="/p/baphy/source/detail?spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c&r=1100f69d18244524aa7c38269c9061b204b69844">1100f69d1824</a>
 by Stephen David &lt;stephen.v.david@gmail.com&gt;
 on May 22, 2014
 &nbsp; <a href="/p/baphy/source/diff?spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c&r=1100f69d18244524aa7c38269c9061b204b69844&amp;format=side&amp;path=/Config/lbhb/TrialObjects/%40RefTarOpt/RandomizeSequence.m&amp;old_path=/Config/lbhb/TrialObjects/%40RefTarOpt/RandomizeSequence.m&amp;old=bd44cd69749a3447864ac78209c8babc32187d8f">Diff</a>
 <br>
 <pre class="ifOpened">small
</pre>
 </div>
 
 <div class="closed" style="margin-bottom:3px;" >
 <a class="ifClosed" onclick="return _toggleHidden(this)"><img src="https://ssl.gstatic.com/codesite/ph/images/plus.gif" ></a>
 <a class="ifOpened" onclick="return _toggleHidden(this)"><img src="https://ssl.gstatic.com/codesite/ph/images/minus.gif" ></a>
 <a href="/p/baphy/source/detail?spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c&r=bd44cd69749a3447864ac78209c8babc32187d8f">bd44cd69749a</a>
 by Stephen David &lt;stephen.v.david@gmail.com&gt;
 on May 22, 2014
 &nbsp; <a href="/p/baphy/source/diff?spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c&r=bd44cd69749a3447864ac78209c8babc32187d8f&amp;format=side&amp;path=/Config/lbhb/TrialObjects/%40RefTarOpt/RandomizeSequence.m&amp;old_path=/Config/lbhb/TrialObjects/%40RefTarOpt/RandomizeSequence.m&amp;old=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3">Diff</a>
 <br>
 <pre class="ifOpened">Working on RefTarOpt.m implementation.
</pre>
 </div>
 
 <div class="closed" style="margin-bottom:3px;" >
 <a class="ifClosed" onclick="return _toggleHidden(this)"><img src="https://ssl.gstatic.com/codesite/ph/images/plus.gif" ></a>
 <a class="ifOpened" onclick="return _toggleHidden(this)"><img src="https://ssl.gstatic.com/codesite/ph/images/minus.gif" ></a>
 <a href="/p/baphy/source/detail?spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c&r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3">5f8ae5ec007e</a>
 by Stephen David &lt;davids@ohsu.edu&gt;
 on May 21, 2014
 &nbsp; <a href="/p/baphy/source/diff?spec=svne8a83f1978e8252fc8f4030b6d6a882f0e87739c&r=5f8ae5ec007ebfa3f58c90785aa90c85ed941cd3&amp;format=side&amp;path=/Config/lbhb/TrialObjects/%40RefTarOpt/RandomizeSequence.m&amp;old_path=/Config/lbhb/TrialObjects/%40RefTarOpt/RandomizeSequence.m&amp;old=">Diff</a>
 <br>
 <pre class="ifOpened">Starting to add optical stimulus
channel option.
\
</pre>
 </div>
 
 
 <a href="/p/baphy/source/list?path=/Config/lbhb/TrialObjects/%40RefTarOpt/RandomizeSequence.m&r=df1ce621640fea56f24c26821121397f3c6a9c4c">All revisions of this file</a>
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
 
 <div>Size: 4859 bytes,
 119 lines</div>
 
 <div><a href="//baphy.googlecode.com/git/Config/lbhb/TrialObjects/@RefTarOpt/RandomizeSequence.m">View raw file</a></div>
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
 var paths = {'svne8a83f1978e8252fc8f4030b6d6a882f0e87739c': '/Config/lbhb/TrialObjects/@RefTarOpt/RandomizeSequence.m'}
 codereviews = CR_controller.setup(
 {"token": "ABZ6GAcEsfN1y96Qt3jsv6K7oZN1VM6OQA:1410858462452", "projectHomeUrl": "/p/baphy", "profileUrl": "/u/105489876805901808296/", "assetVersionPath": "https://ssl.gstatic.com/codesite/ph/17097911804237236952", "assetHostPath": "https://ssl.gstatic.com/codesite/ph", "domainName": null, "relativeBaseUrl": "", "projectName": "baphy", "loggedInUserEmail": "boubenec@gmail.com"}, '', 'svne8a83f1978e8252fc8f4030b6d6a882f0e87739c', paths,
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

