EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L MCU_Module:Arduino_UNO_R3 A1
U 1 1 5EC4DF89
P 3650 2500
F 0 "A1" H 4500 3350 50  0000 C CNN
F 1 "Arduino_UNO_R3" H 4500 3250 50  0000 C CNN
F 2 "Module:Arduino_UNO_R3" H 3650 2500 50  0001 C CIN
F 3 "https://www.arduino.cc/en/Main/arduinoBoardUno" H 3650 2500 50  0001 C CNN
	1    3650 2500
	1    0    0    -1  
$EndComp
$Comp
L Device:R R1
U 1 1 5EC52085
P 5100 3050
F 0 "R1" H 5170 3096 50  0000 L CNN
F 1 "220" H 5170 3005 50  0000 L CNN
F 2 "" V 5030 3050 50  0001 C CNN
F 3 "~" H 5100 3050 50  0001 C CNN
	1    5100 3050
	1    0    0    -1  
$EndComp
$Comp
L Device:LED D1
U 1 1 5EC546CD
P 5100 3500
F 0 "D1" V 5139 3382 50  0000 R CNN
F 1 "LED" V 5048 3382 50  0000 R CNN
F 2 "" H 5100 3500 50  0001 C CNN
F 3 "~" H 5100 3500 50  0001 C CNN
	1    5100 3500
	0    -1   -1   0   
$EndComp
Wire Wire Line
	5100 3750 3750 3750
Wire Wire Line
	3750 3750 3750 3600
Wire Wire Line
	5100 2800 4150 2800
Wire Wire Line
	5100 3350 5100 3200
Wire Wire Line
	5100 2900 5100 2800
Wire Wire Line
	5100 3650 5100 3750
$Comp
L pspice:VSOURCE V1
U 1 1 5EC58BEC
P 2350 2500
F 0 "V1" H 2578 2546 50  0000 L CNN
F 1 "dc 9" H 2578 2455 50  0000 L CNN
F 2 "" H 2350 2500 50  0001 C CNN
F 3 "~" H 2350 2500 50  0001 C CNN
	1    2350 2500
	1    0    0    -1  
$EndComp
Wire Wire Line
	2350 2200 2350 1200
Wire Wire Line
	2350 2800 2350 3750
Wire Wire Line
	2350 3750 3550 3750
Wire Wire Line
	3550 3750 3550 3600
Wire Wire Line
	2350 1200 3550 1200
Wire Wire Line
	3550 1200 3550 1500
$EndSCHEMATC
