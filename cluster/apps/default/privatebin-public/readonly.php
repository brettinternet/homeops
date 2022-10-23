<?php
use PrivateBin\I18n;
?><!DOCTYPE html>
<html lang="<?php echo I18n::_('en'); ?>">
	<head>
		<meta charset="utf-8" />
		<meta http-equiv="Content-Security-Policy" content="<?php echo I18n::encode($CSPHEADER); ?>">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta name="robots" content="noindex" />
		<meta name="google" content="notranslate">
		<title><?php echo I18n::_($NAME); ?></title>
		<link type="text/css" rel="stylesheet" href="css/bootstrap/bootstrap-3.4.1.css" />
		<link type="text/css" rel="stylesheet" href="css/bootstrap/bootstrap-theme-3.4.1.css" />
		<link type="text/css" rel="stylesheet" href="css/bootstrap/privatebin.css?<?php echo rawurlencode($VERSION); ?>" />
<?php
if ($SYNTAXHIGHLIGHTING) :
?>
		<link type="text/css" rel="stylesheet" href="css/prettify/prettify.css?<?php echo rawurlencode($VERSION); ?>" />
<?php
    if (strlen($SYNTAXHIGHLIGHTINGTHEME)) :
?>
		<link type="text/css" rel="stylesheet" href="css/prettify/<?php echo rawurlencode($SYNTAXHIGHLIGHTINGTHEME); ?>.css?<?php echo rawurlencode($VERSION); ?>" />
<?php
    endif;
endif;
?>
		<noscript><link type="text/css" rel="stylesheet" href="css/noscript.css" /></noscript>
		<script type="text/javascript" data-cfasync="false" src="js/jquery-3.6.0.js"
		integrity="sha512-894YE6QWD5I59HgZOGReFYm4dnWc1Qt5NtvYSaNcOP+u1T9qYdvdihz0PPSiiqn/+/3e7Jo4EaG7TubfWGUrMQ=="
		crossorigin="anonymous"></script>
<?php
if ($QRCODE) :
?>
		<script async type="text/javascript" data-cfasync="false" src="js/kjua-0.9.0.js" integrity="sha512-CVn7af+vTMBd9RjoS4QM5fpLFEOtBCoB0zPtaqIDC7sF4F8qgUSRFQQpIyEDGsr6yrjbuOLzdf20tkHHmpaqwQ==" crossorigin="anonymous"></script>
<?php
endif;
if ($ZEROBINCOMPATIBILITY) :
?>
		<script type="text/javascript" data-cfasync="false" src="js/base64-1.7.js" integrity="sha512-JdwsSP3GyHR+jaCkns9CL9NTt4JUJqm/BsODGmYhBcj5EAPKcHYh+OiMfyHbcDLECe17TL0hjXADFkusAqiYgA==" crossorigin="anonymous"></script>
<?php
endif;
?>
		<script type="text/javascript" data-cfasync="false" src="js/zlib-1.2.12.js" integrity="sha512-Ewve1dyEW/Vf97OY91/aWqMx9NaaUK5d8Z6JB1RR5gFXtMhse/Ya7D/5CE/UrQTwOWqmkvn97JjP4YDUrmq/yA==" crossorigin="anonymous"></script>
		<script type="text/javascript" data-cfasync="false" src="js/base-x-4.0.0.js" integrity="sha512-nNPg5IGCwwrveZ8cA/yMGr5HiRS5Ps2H+s0J/mKTPjCPWUgFGGw7M5nqdnPD3VsRwCVysUh3Y8OWjeSKGkEQJQ==" crossorigin="anonymous"></script>
		<script type="text/javascript" data-cfasync="false" src="js/rawinflate-0.3.js" integrity="sha512-g8uelGgJW9A/Z1tB6Izxab++oj5kdD7B4qC7DHwZkB6DGMXKyzx7v5mvap2HXueI2IIn08YlRYM56jwWdm2ucQ==" crossorigin="anonymous"></script>
		<script type="text/javascript" data-cfasync="false" src="js/bootstrap-3.4.1.js" integrity="sha512-oBTprMeNEKCnqfuqKd6sbvFzmFQtlXS3e0C/RGFV0hD6QzhHV+ODfaQbAlmY6/q0ubbwlAM/nCJjkrgA3waLzg==" crossorigin="anonymous"></script>
<?php
if ($SYNTAXHIGHLIGHTING) :
?>
		<script type="text/javascript" data-cfasync="false" src="js/prettify.js?<?php echo rawurlencode($VERSION); ?>" integrity="sha512-puO0Ogy++IoA2Pb9IjSxV1n4+kQkKXYAEUtVzfZpQepyDPyXk8hokiYDS7ybMogYlyyEIwMLpZqVhCkARQWLMg==" crossorigin="anonymous"></script>
<?php
endif;
if ($MARKDOWN) :
?>
		<script type="text/javascript" data-cfasync="false" src="js/showdown-2.0.3.js" integrity="sha512-vcfjvW3UKHD/4vlQx804cqWK88jFmjsWRsZ8/u5YEcyHB1IituxrXDU7TvdqsFVsMnxpE/UIEo25/SYW+puWHw==" crossorigin="anonymous"></script>
<?php
endif;
?>
		<script type="text/javascript" data-cfasync="false" src="js/purify-2.3.6.js" integrity="sha512-N1GGPjbqLbwK821ZN7C925WuTwU4aDxz2CEEOXQ6/s6m6MBwVj8fh5fugiE2hzsm0xud3q7jpjZQ4ILnpMREYQ==" crossorigin="anonymous"></script>
		<script type="text/javascript" data-cfasync="false" src="js/legacy.js?<?php echo rawurlencode($VERSION); ?>" integrity="sha512-LYos+qXHIRqFf5ZPNphvtTB0cgzHUizu2wwcOwcwz/VIpRv9lpcBgPYz4uq6jx0INwCAj6Fbnl5HoKiLufS2jg==" crossorigin="anonymous"></script>
		<script type="text/javascript" data-cfasync="false" src="js/privatebin.js?<?php echo rawurlencode($VERSION); ?>" integrity="sQhu+q8ayRj0LO80orHnhEudlTf5Qx+Yhb/+U84ixMvSdwijuLEHGiEuWctqUPOFSe56L6aeq6z7K0ONpbgaew==" crossorigin="anonymous"></script>
		<!-- icon -->
		<link rel="apple-touch-icon" href="<?php echo I18n::encode($BASEPATH); ?>img/apple-touch-icon.png" sizes="180x180" />
		<link rel="icon" type="image/png" href="img/favicon-32x32.png" sizes="32x32" />
		<link rel="icon" type="image/png" href="img/favicon-16x16.png" sizes="16x16" />
		<link rel="manifest" href="manifest.json?<?php echo rawurlencode($VERSION); ?>" />
		<link rel="mask-icon" href="img/safari-pinned-tab.svg" color="#ffcc00" />
		<link rel="shortcut icon" href="img/favicon.ico">
		<meta name="msapplication-config" content="browserconfig.xml">
		<meta name="theme-color" content="#ffe57e" />
		<!-- Twitter/social media cards -->
		<meta name="twitter:card" content="summary" />
		<meta name="twitter:title" content="<?php echo I18n::_('Encrypted note on PrivateBin') ?>" />
		<meta name="twitter:description" content="<?php echo I18n::_('Visit this link to see the note. Giving the URL to anyone allows them to access the note, too.') ?>" />
		<meta name="twitter:image" content="<?php echo I18n::encode($BASEPATH); ?>img/apple-touch-icon.png" />
		<meta property="og:title" content="<?php echo I18n::_($NAME); ?>" />
		<meta property="og:site_name" content="<?php echo I18n::_($NAME); ?>" />
		<meta property="og:description" content="<?php echo I18n::_('Visit this link to see the note. Giving the URL to anyone allows them to access the note, too.') ?>" />
		<meta property="og:image" content="<?php echo I18n::encode($BASEPATH); ?>img/apple-touch-icon.png" />
		<meta property="og:image:type" content="image/png" />
		<meta property="og:image:width" content="180" />
		<meta property="og:image:height" content="180" />
	</head>
	<body role="document" data-compression="<?php echo rawurlencode($COMPRESSION); ?>" class="navbar-spacing">
		<div id="passwordmodal" tabindex="-1" class="modal fade" role="dialog" aria-hidden="true">
			<div class="modal-dialog" role="document">
				<div class="modal-content">
					<div class="modal-body">
						<form id="passwordform" role="form">
							<div class="form-group">
								<label for="passworddecrypt"><span class="glyphicon glyphicon-eye-open"></span> <?php echo I18n::_('Please enter the password for this paste:') ?></label>
								<input id="passworddecrypt" type="password" class="form-control" placeholder="<?php echo I18n::_('Enter password') ?>" required="required">
							</div>
							<button type="submit" class="btn btn-success btn-block"><span class="glyphicon glyphicon-off"></span> <?php echo I18n::_('Decrypt') ?></button>
						</form>
					</div>
				</div>
			</div>
		</div>
<?php
if ($QRCODE) :
?>
		<div id="qrcodemodal" tabindex="-1" class="modal fade" aria-labelledby="qrcodemodalTitle" role="dialog" aria-hidden="true">
			<div class="modal-dialog" role="document">
				<div class="modal-content">
					<div class="modal-body">
						<div class="mx-auto" id="qrcode-display"></div>
					</div>
					<div class="row">
						<div class="btn-group col-xs-12">
							<span class="col-xs-12">
								<button type="button" class="btn btn-primary btn-block" data-dismiss="modal"><?php echo I18n::_('Close') ?></button>
							</span>
						</div>
					</div>
				</div>
			</div>
		</div>
<?php
endif;
?>
		<div id="emailconfirmmodal" tabindex="-1" class="modal fade" aria-labelledby="emailconfirmmodalTitle" role="dialog" aria-hidden="true">
			<div class="modal-dialog" role="document">
				<div class="modal-content">
					<div class="modal-body">
						<div id="emailconfirm-display"></div>
					</div>
					<div class="row">
						<div class="btn-group col-xs-12" data-toggle="buttons">
							<span class="col-xs-12 col-md-4">
								<button id="emailconfirm-timezone-current" type="button" class="btn btn-danger btn-block" data-dismiss="modal"><?php echo I18n::_('Use Current Timezone') ?></button>
							</span>
							<span class="col-xs-12 col-md-4">
								<button id="emailconfirm-timezone-utc" type="button" class="btn btn-default btn-block" data-dismiss="modal"><?php echo I18n::_('Convert To UTC') ?></button>
							</span>
							<span class="col-xs-12 col-md-4">
								<button type="button" class="btn btn-primary btn-block" data-dismiss="modal"><?php echo I18n::_('Close') ?></button>
							</span>
						</div>
					</div>
				</div>
			</div>
		</div>
		<nav class="navbar navbar-default navbar-fixed-top">
			<div class="container">
			<div class="navbar-header">
				<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
					<span class="sr-only"><?php echo I18n::_('Toggle navigation'); ?></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
				</button>
				<a class="reloadlink navbar-brand" href="">
					<img alt="<?php echo I18n::_($NAME); ?>" src="img/icon.svg" width="38" />
				</a>
			</div>
			<div id="navbar" class="navbar-collapse collapse">
				<ul class="nav navbar-nav">
					<li id="loadingindicator" class="navbar-text hidden">
						<span class="glyphicon glyphicon-time" aria-hidden="true"></span>
						<?php echo I18n::_('Loading…'), PHP_EOL; ?>
					</li>
					<li>
						<button id="retrybutton" type="button" class="reloadlink hidden btn btn-primary navbar-btn">
							<span class="glyphicon glyphicon-repeat" aria-hidden="true"></span> <?php echo I18n::_('Retry'), PHP_EOL; ?>
						</button>
					</li>
					<li>
						<button id="rawtextbutton" type="button" class="hidden btn btn-default navbar-btn">
							<span class="glyphicon glyphicon-text-background" aria-hidden="true"></span> <?php echo I18n::_('Raw text'), PHP_EOL; ?>
						</button>
						<button id="downloadtextbutton" type="button" class="hidden btn btn-default navbar-btn">
							<span class="glyphicon glyphicon glyphicon-download-alt" aria-hidden="true"></span> <?php echo I18n::_('Save paste'), PHP_EOL; ?>
						</button>
						<button id="emaillink" type="button" class="hidden btn btn-default navbar-btn">
							<span class="glyphicon glyphicon-envelope" aria-hidden="true"></span> <?php echo I18n::_('Email'), PHP_EOL; ?>
						</button>
<?php
if ($QRCODE) :
?>
						<button id="qrcodelink" type="button" data-toggle="modal" data-target="#qrcodemodal" class="hidden btn btn-default navbar-btn">
							<span class="glyphicon glyphicon-qrcode" aria-hidden="true"></span> <?php echo I18n::_('QR code'), PHP_EOL; ?>
						</button>
<?php
endif;
?>
					</li>
					<li class="dropdown">
						<a id="formatter" href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><?php echo I18n::_('Options'); ?> <span class="caret"></span></a>
						<ul class="dropdown-menu">
							<li>
								<div>
									<?php echo I18n::_('Format'); ?>: <span id="pasteFormatterDisplay"><?php echo $FORMATTER[$FORMATTERDEFAULT]; ?></span> <span class="caret"></span>
								</div>
							</li>
<?php
    foreach ($FORMATTER as $key => $value) :
?>
							<li>
								<a href="#" data-format="<?php echo $key; ?>">
									<?php echo $value, PHP_EOL; ?>
								</a>
							</li>
<?php
    endforeach;
?>
						</ul>
						<select id="pasteFormatter" name="pasteFormatter" class="hidden">
<?php
    foreach ($FORMATTER as $key => $value) :
?>
							<option value="<?php echo $key; ?>"<?php
        if ($key == $FORMATTERDEFAULT) :
?> selected="selected"<?php
        endif;
?>><?php echo $value; ?></option>
<?php
    endforeach;
?>
						</select>
					</li>
					<li class="dropdown">
						<select id="pasteFormatter" name="pasteFormatter" class="hidden">
<?php
    foreach ($FORMATTER as $key => $value) :
?>
							<option value="<?php echo $key; ?>"<?php
        if ($key == $FORMATTERDEFAULT) :
?> selected="selected"<?php
        endif;
?>><?php echo $value; ?></option>
<?php
    endforeach;
?>
						</select>
						<a id="formatter" href="#" class="hidden dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><?php echo I18n::_('Format'); ?>: <span id="pasteFormatterDisplay"><?php echo $FORMATTER[$FORMATTERDEFAULT]; ?></span> <span class="caret"></span></a>
						<ul class="dropdown-menu">
<?php
    foreach ($FORMATTER as $key => $value) :
?>
							<li>
								<a href="#" data-format="<?php echo $key; ?>">
									<?php echo $value, PHP_EOL; ?>
								</a>
							</li>
<?php
    endforeach;
?>
						</ul>
					</li>
				</ul>
				<ul class="nav navbar-nav pull-right">
<?php
if (strlen($LANGUAGESELECTION)) :
?>
					<li id="language" class="dropdown">
						<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><span class="glyphicon glyphicon-flag" aria-hidden="true"></span> <?php echo $LANGUAGES[$LANGUAGESELECTION][0]; ?> <span class="caret"></span></a>
						<ul class="dropdown-menu dropdown-menu-right">
<?php
    foreach ($LANGUAGES as $key => $value) :
?>
							<li>
								<a href="#" data-lang="<?php echo $key; ?>">
									<?php echo $value[0]; ?> (<?php echo $value[1]; ?>)
								</a>
							</li>
<?php
    endforeach;
?>
						</ul>
					</li>
<?php
endif;
?>
				</ul>
			</div>
		</div>
		</nav>
		<main>
			<section class="container">
<?php
if (strlen($NOTICE)) :
?>
				<div role="alert" class="alert alert-info">
					<span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span>
					<?php echo I18n::encode($NOTICE), PHP_EOL; ?>
				</div>
<?php
endif;
?>
				<div id="remainingtime" role="alert" class="hidden alert alert-info">
					<span class="glyphicon glyphicon-fire" aria-hidden="true"></span>
				</div>
<?php
if ($FILEUPLOAD) :
?>
				<div id="attachment" role="alert" class="hidden alert alert-info">
					<span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span>
					<a class="alert-link"><?php echo I18n::_('Download attachment'), PHP_EOL; ?></a>
				</div>
<?php
endif;
?>
				<div id="status" role="alert" class="alert alert-info<?php echo empty($STATUS) ? ' hidden' : '' ?>">
					<span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span>
					<?php echo I18n::encode($STATUS), PHP_EOL; ?>
				</div>
				<div id="errormessage" role="alert" class="<?php echo empty($ERROR) ? 'hidden' : '' ?> alert alert-danger">
					<span class="glyphicon glyphicon-alert" aria-hidden="true"></span>
					<?php echo I18n::encode($ERROR), PHP_EOL; ?>
				</div>
				<noscript>
					<div id="noscript" role="alert" class="alert alert-warning">
						<span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
						<?php echo I18n::_('JavaScript is required for %s to work.', I18n::_($NAME)), PHP_EOL; ?>
					</div>
				</noscript>
				<div id="oldnotice" role="alert" class="hidden alert alert-danger">
					<span class="glyphicon glyphicon-alert" aria-hidden="true"></span>
					<?php echo I18n::_('%s requires a modern browser to work.', I18n::_($NAME)), PHP_EOL; ?>
					<a href="https://www.mozilla.org/firefox/">Firefox</a>,
					<a href="https://www.opera.com/">Opera</a>,
					<a href="https://www.google.com/chrome">Chrome</a>…<br />
					<span class="small"><?php echo I18n::_('For more information <a href="%s">see this FAQ entry</a>.', 'https://github.com/PrivateBin/PrivateBin/wiki/FAQ#why-does-it-show-me-the-error-privatebin-requires-a-modern-browser-to-work'); ?></span>
				</div>
<?php
if ($HTTPWARNING) :
?>
				<div id="httpnotice" role="alert" class="hidden alert alert-danger">
					<span class="glyphicon glyphicon-alert" aria-hidden="true"></span>
					<?php echo I18n::_('This website is using an insecure connection! Please only use it for testing.'), PHP_EOL; ?><br />
					<span class="small"><?php echo I18n::_('For more information <a href="%s">see this FAQ entry</a>.', 'https://github.com/PrivateBin/PrivateBin/wiki/FAQ#why-does-it-show-me-an-error-about-an-insecure-connection'); ?></span>
				</div>
				<div id="insecurecontextnotice" role="alert" class="hidden alert alert-danger">
					<span class="glyphicon glyphicon-alert" aria-hidden="true"></span>
					<?php echo I18n::_('Your browser may require an HTTPS connection to support the WebCrypto API. Try <a href="%s">switching to HTTPS</a>.', $HTTPSLINK); ?>
				</div>
<?php
endif;
?>
				<div id="pastesuccess" class="hidden">
					<div role="alert" class="alert alert-success">
						<span class="glyphicon glyphicon-ok" aria-hidden="true"></span>
						<div id="deletelink"></div>
						<div id="pastelink"></div>
					</div>
<?php
if (strlen($URLSHORTENER)) :
?>
					<p>
						<button id="shortenbutton" data-shortener="<?php echo I18n::encode($URLSHORTENER); ?>" type="button" class="btn btn-primary btn-block">
						<span class="glyphicon glyphicon-send" aria-hidden="true"></span> <?php echo I18n::_('Shorten URL'), PHP_EOL; ?>
					</button>
					</p>
					<div role="alert" class="alert alert-danger">
						<span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
						<?php echo I18n::_('URL shortener may expose your decrypt key in URL.'), PHP_EOL; ?>
					</div>
<?php
endif;
?>
				</div>
			</section>
			<section class="container">
				<article class="row">
					<div id="placeholder" class="col-md-12 hidden"><?php echo I18n::_('+++ no paste text +++'); ?></div>
					<div id="attachmentPreview" class="col-md-12 text-center hidden"></div>
					<div id="prettymessage" class="col-md-12 hidden">
						<pre id="prettyprint" class="col-md-12 prettyprint linenums:1"></pre>
					</div>
					<div id="plaintext" class="col-md-12 hidden"></div>
					<div id="message" class="col-md-12 hidden">
						<p role="alert" class="alert alert-info">
							<?php echo I18n::_('%s is a read-only', I18n::_($NAME)), PHP_EOL; ?>
							<a href="https://privatebin.info"><?php echo I18n::_('PrivateBin'); ?></a>
							<?php echo I18n::_('server.'), PHP_EOL; ?>
						</p>
					</div>
				</article>
			</section>
			<section class="container">
				<div id="discussion" class="hidden">
					<h4><?php echo I18n::_('Discussion'); ?></h4>
					<div id="commentcontainer"></div>
				</div>
			</section>
			<section class="container">
				<div id="noscript" role="alert" class="alert alert-info noscript-hide">
					<span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
					<?php echo I18n::_('Loading…'); ?>
				</div>
			</section>
		</main>
<?php
if ($DISCUSSION) :
?>
		<div id="serverdata" class="hidden" aria-hidden="true">
			<div id="templates">
				<article id="commenttemplate" class="comment"><div class="commentmeta"><span class="nickname">name</span><span class="commentdate">0000-00-00</span></div><div class="commentdata">c</div><button class="btn btn-default btn-sm"><?php echo I18n::_('Reply'); ?></button></article>
				<p id="commenttailtemplate" class="comment"><button class="btn btn-default btn-sm"><?php echo I18n::_('Add comment'); ?></button></p>
				<div id="replytemplate" class="reply hidden"><input type="text" id="nickname" class="form-control" title="<?php echo I18n::_('Optional nickname…'); ?>" placeholder="<?php echo I18n::_('Optional nickname…'); ?>" /><textarea id="replymessage" class="replymessage form-control" cols="80" rows="7"></textarea><br /><div id="replystatus" role="alert" class="statusmessage hidden alert"><span class="glyphicon" aria-hidden="true"></span> </div><button id="replybutton" class="btn btn-default btn-sm"><?php echo I18n::_('Post comment'); ?></button></div>
			</div>
		</div>
<?php
endif;
?>
<?php
if ($FILEUPLOAD) :
?>
		<div id="dropzone" class="hidden" tabindex="-1" aria-hidden="true"></div>
<?php
endif;
?>
	</body>
</html>
