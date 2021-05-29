<?php
    $static_app_01 = getenv('STATIC_APP_01');
    $static_app_02 = getenv('STATIC_APP_02');
    $dynamic_app_01 = getenv('DYNAMIC_APP_01');
    $dynamic_app_02 = getenv('DYNAMIC_APP_02');
?>

<VirtualHost *:80>
    ServerName address.res.ch
    
    Header add Set-Cookie "ROUTEID=.%{BALANCER_WORKER_ROUTE}e; path=/" env=BALANCER_ROUTE_CHANGED

    <Proxy balancer://dynamic_app>
        BalancerMember 'http://<?php print "$dynamic_app_01"?>'
        BalancerMember 'http://<?php print "$dynamic_app_02"?>'
    </Proxy>

    <Proxy balancer://static_app>
        BalancerMember 'http://<?php print "$static_app_01"?>' route=1
        BalancerMember 'http://<?php print "$static_app_02"?>' route=2
        ProxySet stickysession=ROUTEID
    </Proxy>

    ProxyPass '/api/address/' 'balancer://dynamic_app/'
    ProxyPassReverse '/api/address/' 'balancer://dynamic_app/'

    ProxyPass '/' 'balancer://static_app/'
    ProxyPassReverse '/' 'balancer://static_app/'
</VirtualHost>
