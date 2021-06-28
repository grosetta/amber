#!/bin/bash
COMMOND=pmemd.cuda
COM=
################################################################################
# 3、运行模拟
################################################################################
echo '正在进行能量最小化...'
# 3.1 能量最小化
echo "Minimize
&cntrl
 imin=1,maxcyc=2000,ncyc=1000,
 cut=10,ntb=10,ntwx=10
 ntc=1,ntf=1,
 ntpr=500, 
/
" > mini.in

$COMMOND -O -i mini.in -o mini.out -p $COM.prmtop -c $COM.inpcrd -r ${COM}_mini.rst -ref $COM.inpcrd -x mini.nc

echo '正在加热...'
# 3.2 NVT(升高温度)
echo "Heat
&cntrl
 imin=0,irest=0,ntx=1,
 nstlim=50000,dt=0.001,
 ntc=1,ntf=1,
 cut=10.0, ntb=1,
 ntpr=500, ntwx=500, ntwr=500,
 ntt=3, gamma_ln=2,
 tempi=0.0, temp0=300.0,
 nmropt=1
/
&wt TYPE='TEMP0', istep1=0, istep2=50000,
 value1=0.1, value2=300.0, 
/
&wt 
 TYPE='END' 
/
" > heat.in

$COMMOND -O -i heat.in -o heat.out -p $COM.prmtop -c ${COM}_mini.rst -r ${COM}_heat.rst -ref ${COM}_mini.rst

echo '预平衡...'
#3.3 预平衡
echo "Production
&cntrl
 imin=0,irest=1,ntx=5,
 iwrap=1,
 nstlim=50000,dt=0.001,
 ntc=2,ntf=2,
 cut=10.0, ntb=2, ntp=1, taup=2.0,
 ntpr=500, ntwx=500, ntwr=500,
 ntt=3, gamma_ln=2.0,
 temp0=300.0,
/ 
" > eq.in

$COMMOND -O -i eq.in -o eq.out -p $COM.prmtop -c ${COM}_heat.rst -r ${COM}_eq.rst -ref ${COM}_heat.rst

echo '成品模拟...'
# 3.4 成品模拟(最好分步模拟)
echo "Production
&cntrl
 imin=0,irest=1,ntx=5,
 iwrap=1,
 nstlim=5000,dt=0.002,
 ntc=2,ntf=2,
 cut=10, ntb=2, ntp=1, taup=2.0,
 ntpr=50, ntwx=50, ntwr=50,
 ntt=3, gamma_ln=2.0,
 temp0=300.0, 
/
" > md.in

$COMMOND -O -i md.in -o md1.out -p $COM.prmtop -c ${COM}_eq.rst   -r ${COM}_md_1.rst -x md_1.nc -inf mdinfo_1
$COMMOND -O -i md.in -o md2.out -p $COM.prmtop -c ${COM}_md_1.rst -r ${COM}_md_2.rst -x md_2.nc -inf mdinfo_2
$COMMOND -O -i md.in -o md3.out -p $COM.prmtop -c ${COM}_md_2.rst -r ${COM}_md_3.rst -x md_3.nc -inf mdinfo_3
$COMMOND -O -i md.in -o md4.out -p $COM.prmtop -c ${COM}_md_3.rst -r ${COM}_md_4.rst -x md_4.nc -inf mdinfo_4
$COMMOND -O -i md.in -o md5.out -p $COM.prmtop -c ${COM}_md_4.rst -r ${COM}_md_5.rst -x md_5.nc -inf mdinfo_5

echo '完成模拟'

rm -f *.in *.out *.rst