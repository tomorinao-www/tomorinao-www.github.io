set ALL_PROXY=http://127.0.0.1:7890
call hexo clean
call hexo g
call hexo deployr --config  _config.yml,_config.arknights.yml   
pause