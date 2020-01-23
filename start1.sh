#this script should be run only after having /root/build in router

file=/usr/bin/nodogsplash
file1=/root/build/socketman_v1_mips_24kc.ipk
file2=/usr/bin/socketman
newip=10.10.1.100
port=7070
url=http://$newip:$port/v1.0/init
eid=123456



router(){
        opkg update
	opkg install bash
        opkg install qos-scripts
        uci set wireless.default_radio0.network='lan'
	uci set wireless.default_radio1.network='lan'
	uci commit wireless
	wifi

}

socketman(){
           opkg update
           opkg install libndpi
           if [ -f "$file1" ]; then
                opkg install /root/build/socketman_v1_mips_24kc.ipk
                sleep 5
           else
                echo  "unable to find /root/build/socketman_v1_mips_24kc.ipk"
                exit 1
           fi
           if [ -f "$file2" ]; then
                echo  "socketman is installed"      
                echo "new socketman is updating"
           else
                echo  "unable to install socketman"
                exit 1
           fi
		   
		   
           test -f /usr/bin/socketman_org || mv /usr/bin/socketman /usr/bin/socketman_org
           cp /root/build/socketman /usr/bin
           cp /root/build/config.json /etc
           mv /etc/config.json /etc/socketman
           mac="$(ifconfig br-lan | awk '/HWaddr/{print $5}' | sed 's/:/-/g')"
           echo "${mac}"
	   sed -i -r 's/([0-9]{1,3}\.){3}[0-9]{1,3}\:[0-9]{1,5}'/$newip:$port/g /etc/socketman
           #sed -i -r 's/([0-9]{1,3}\.){3}[0-9]{1,3}'/$newip/g /etc/socketman
           #sed -i -r 's/([0-9A-Z]{1,2}\-){5}[0-9A-Z]{1,2}'/$mac/g /etc/socketman
	   sed -i -r 's/([0-9A-Z]{2}[\:\-]{1}){5}[0-9A-Z]{2}'/$mac/g /etc/socketman
	   sed -i '/eid/c\  "eid": "'$eid'",' /etc/socketman
           if grep -q "http" /etc/init.d/socketman
           then
	           sed -i "/http/c AUTHURL="${url}"" /etc/init.d/socketman
			   sed -i '/procd_set_param command/c\  procd_set_param command "$PROG" --config="$CONFIGFILE" -b "$AUTHURL"' /etc/init.d/socketman
	           echo "hi"
           else
                   sed -i "/^STOP/a AUTHURL="${url}"" /etc/init.d/socketman
                   sed -i '/procd_set_param command/c\  procd_set_param command "$PROG" --config="$CONFIGFILE" -b "$AUTHURL"' /etc/init.d/socketman
                   echo "hi2"
           fi
           chmod +x /usr/bin/socketman
           service socketman restart

}


nodogsplash{
           opkg update
           opkg install nodogsplash
	   sleep 10
	   if [ -f "$file" ]; then
                echo  "nodosplash is installed"
           else
                echo  "unable to install nodosplash"
                exit 1
           fi

}

user_password(){       
        #under
        test -d /etc/justifi || mkdir -p /etc/justifi                                                                                         
        cd /root/build/user_passwd/                                                                                                           
        cp splash.css splash.html status.html jupiter-logo.png /etc/nodogsplash/htdocs/                                                       
        cp access.log user_list json_gen.sh nds_auth.sh /etc/justifi                                                                          
        cp nodogsplash /etc/config                                                                                                            
        sed -i "/gatewayname/c\  option gatewayname '$mac\_$eid'" /etc/config/nodogsplash                                                       
        chmod +x /etc/justifi/json_gen.sh                                       
        chmod +x /etc/justifi/nds_auth.sh                                                                                                                                                                             
}                                                                                                                                             
                                                                                                                                              
otp(){
        #under
        test -d /etc/justifi || mkdir -p /etc/justifi                                                                                         
        cd /root/build/otp/                                                                                                                   
        cp json_gen.sh /etc/justifi                                                                                                           
        cp nodogsplash /etc/config
        chmod +x /etc/justifi/json_gen.sh
                                                                                                                                              
}                                                                                                                                             
                                                                                                                                              
                                                                                                                                              
case $1 in                                                                                                                                    
        router)                                                                                                                               
                router                                                                                                                        
                ;;                                                                                                                            
        socketman)                                                                                                                            
                socketman                                                                                                                     
                ;;                                                                                                                            
        nodogsplash)                                                                                                                          
                nodogsplash                                                                                                                   
                exit 1                                                                                                                        
                ;;                                                                                                                            
esac                                                                                                                                          

sed -i '/^\s*option faspath/c\  option faspath "index.php"' /root/build2/test.sh
#changes on init.d,"br-wan in /var/state get network.wan.ifname", port
#sed -i -r 's/([0-9]{1,3}\.){3}[0-9]{1,3}\:[0-9]{1,5}'/10.10.1.10:9000/g /etc/socketman
#eid in /etc/socketman need to be added
#sed -i -r 's/([0-9A-Z]{2}[\:\-]{1}){5}[0-9A-Z]{2}'/AB-AG-AF-AE-AD-AC/g /etc/socketman  (for 48 mac line)
