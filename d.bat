call hexo clean
call hexo g
call hexo deploy --config  _config.yml,_config.arknights.yml,.nao_config.yml
call ssh root@23.95.227.104 "cd /var/www/tomorinao-www.github.io && git pull  && git checkout gh-pages && git pull"
rem echo put -r public/* | sftp  root@121.40.221.30:/var/www/hexo/public/
rem echo put -r public/* | sftp  root@23.95.227.104:/var/www/hexo/public/
pause
