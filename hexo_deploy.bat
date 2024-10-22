call hexo clean
call hexo g --config _config.yml,_config.arknights.yml,_config_deploy.yml
call withclash.bat
call hexo deploy --config _config.yml,_config.arknights.yml,_config_deploy.yml
pause
