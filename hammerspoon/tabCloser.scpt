FasdUAS 1.101.10   ��   ��    k             l     ����  r       	  J     ����   	 o      ���� 0 listtoclose listToClose��  ��     
  
 l    ����  r        n        2   ��
�� 
cpar  l    ����  I   �� ��
�� .rdwrread****        ****  4    	�� 
�� 
psxf  m       �   : / U s e r s / p a u l j o h n s o n / . b l o c k l i s t��  ��  ��    o      ���� 0 listtoclose listToClose��  ��        l    ����  r        J    ����    o      ���� 
0 closed  ��  ��        l     ��������  ��  ��        l      ��   ��   ,&tell application "Safari"	set windowList to every window	repeat with theWindow in windowList		set tabList to every tab in theWindow		set tabList to reverse of tabList		repeat with t in tabList			set tabURL to URL of t			repeat with blockedURL in listToClose				if contents of blockedURL is not "" and tabURL contains (contents of blockedURL) and tabURL is not in closed then					# log tabURL					# log t					# log blockedURL					tell t to close					set end of closed to tabURL				end if			end repeat		end repeat	end repeatend tell      � ! !L  t e l l   a p p l i c a t i o n   " S a f a r i "  	 s e t   w i n d o w L i s t   t o   e v e r y   w i n d o w  	 r e p e a t   w i t h   t h e W i n d o w   i n   w i n d o w L i s t  	 	 s e t   t a b L i s t   t o   e v e r y   t a b   i n   t h e W i n d o w  	 	 s e t   t a b L i s t   t o   r e v e r s e   o f   t a b L i s t  	 	 r e p e a t   w i t h   t   i n   t a b L i s t  	 	 	 s e t   t a b U R L   t o   U R L   o f   t  	 	 	 r e p e a t   w i t h   b l o c k e d U R L   i n   l i s t T o C l o s e  	 	 	 	 i f   c o n t e n t s   o f   b l o c k e d U R L   i s   n o t   " "   a n d   t a b U R L   c o n t a i n s   ( c o n t e n t s   o f   b l o c k e d U R L )   a n d   t a b U R L   i s   n o t   i n   c l o s e d   t h e n  	 	 	 	 	 #   l o g   t a b U R L  	 	 	 	 	 #   l o g   t  	 	 	 	 	 #   l o g   b l o c k e d U R L  	 	 	 	 	 t e l l   t   t o   c l o s e  	 	 	 	 	 s e t   e n d   o f   c l o s e d   t o   t a b U R L  	 	 	 	 e n d   i f  	 	 	 e n d   r e p e a t  	 	 e n d   r e p e a t  	 e n d   r e p e a t  e n d   t e l l    " # " l     ��������  ��  ��   #  $ % $ l     ��������  ��  ��   %  & ' & l   � (���� ( O    � ) * ) k    � + +  , - , r      . / . 2    ��
�� 
cwin / o      ���� 0 
windowlist 
windowList -  0�� 0 X   ! � 1�� 2 1 k   1 � 3 3  4 5 4 r   1 6 6 7 6 n  1 4 8 9 8 2   2 4��
�� 
CrTb 9 o   1 2���� 0 	thewindow 	theWindow 7 o      ���� 0 tablist tabList 5  : ; : r   7 < < = < n   7 : > ? > 1   8 :��
�� 
rvse ? o   7 8���� 0 tablist tabList = o      ���� 0 tablist tabList ;  @�� @ X   = � A�� B A k   M � C C  D E D r   M T F G F n   M P H I H 1   N P��
�� 
URL  I o   M N���� 0 t   G o      ���� 0 taburl tabURL E  J�� J X   U � K�� L K Z   e � M N���� M F   e � O P O F   e ~ Q R Q >  e n S T S n   e j U V U 1   f j��
�� 
pcnt V o   e f���� 0 
blockedurl 
blockedURL T m   j m W W � X X   R E   q z Y Z Y o   q t���� 0 taburl tabURL Z l  t y [���� [ n   t y \ ] \ 1   u y��
�� 
pcnt ] o   t u���� 0 
blockedurl 
blockedURL��  ��   P H   � � ^ ^ E  � � _ ` _ o   � ����� 
0 closed   ` o   � ����� 0 taburl tabURL N k   � � a a  b c b O  � � d e d I  � �������
�� .coreclosnull���     obj ��  ��   e o   � ����� 0 t   c  f�� f r   � � g h g o   � ����� 0 taburl tabURL h n       i j i  ;   � � j o   � ����� 
0 closed  ��  ��  ��  �� 0 
blockedurl 
blockedURL L o   X Y���� 0 listtoclose listToClose��  �� 0 t   B o   @ A���� 0 tablist tabList��  �� 0 	thewindow 	theWindow 2 o   $ %���� 0 
windowlist 
windowList��   * m     k k�                                                                                  rimZ  alis    >  Macintosh HD               �\CBD ����Google Chrome.app                                              ����ީ�K        ����  
 cu             Applications  !/:Applications:Google Chrome.app/   $  G o o g l e   C h r o m e . a p p    M a c i n t o s h   H D  Applications/Google Chrome.app  / ��  ��  ��   '  l m l l     ��������  ��  ��   m  n�� n l  �^ o���� o O   �^ p q p k   �] r r  s t s r   � � u v u 2   � ���
�� 
cwin v o      ���� 0 
windowlist 
windowList t  w�� w X   �] x�� y x k   �X z z  { | { r   � � } ~ } n  � �  �  2   � ���
�� 
bTab � o   � ����� 0 	thewindow 	theWindow ~ o      ���� 0 tablist tabList |  � � � r   � � � � � n   � � � � � 1   � ���
�� 
rvse � o   � ����� 0 tablist tabList � o      ���� 0 tablist tabList �  ��� � X   �X ��� � � k   �S � �  � � � r   � � � � � n   � � � � � 1   � ���
�� 
pURL � o   � ����� 0 t   � o      ���� 0 taburl tabURL �  � � � I  � ��� ���
�� .ascrcmnt****      � **** � o   � ����� 0 taburl tabURL��   �  ��� � X   S ��� � � Z  N � ����� � F  6 � � � F  ) � � � >  � � � n   � � � 1  ��
�� 
pcnt � o  ���� 0 
blockedurl 
blockedURL � m   � � � � �   � E  % � � � o  ���� 0 taburl tabURL � l $ ����� � n  $ � � � 1   $��
�� 
pcnt � o   ���� 0 
blockedurl 
blockedURL��  ��   � H  ,2 � � E ,1 � � � o  ,-���� 
0 closed   � o  -0���� 0 taburl tabURL � k  9J � �  � � � O 9C � � � I =B������
�� .coreclosnull���     obj ��  ��   � o  9:���� 0 t   �  ��� � r  DJ � � � o  DG���� 0 taburl tabURL � n       � � �  ;  HI � o  GH���� 
0 closed  ��  ��  ��  �� 0 
blockedurl 
blockedURL � o  ���� 0 listtoclose listToClose��  �� 0 t   � o   � ����� 0 tablist tabList��  �� 0 	thewindow 	theWindow y o   � ����� 0 
windowlist 
windowList��   q m   � � � ��                                                                                  sfri  alis    p  Preboot                    ���BD ����
Safari.app                                                     �����[��        ����  
 cu             Applications  F/:System:Volumes:Preboot:Cryptexes:App:System:Applications:Safari.app/   
 S a f a r i . a p p    P r e b o o t  -/Cryptexes/App/System/Applications/Safari.app   /System/Volumes/Preboot ��  ��  ��  ��       �� � ���   � ��
�� .aevtoappnull  �   � **** � �� ����� � ���
�� .aevtoappnull  �   � **** � k    ^ � �   � �  
 � �   � �  & � �  n����  ��  ��   � �������� 0 	thewindow 	theWindow�� 0 t  �� 0 
blockedurl 
blockedURL � ���� ����~ k�}�|�{�z�y�x�w�v�u�t�s W�r�q ��p�o�n ��� 0 listtoclose listToClose
�� 
psxf
�� .rdwrread****        ****
� 
cpar�~ 
0 closed  
�} 
cwin�| 0 
windowlist 
windowList
�{ 
kocl
�z 
cobj
�y .corecnte****       ****
�x 
CrTb�w 0 tablist tabList
�v 
rvse
�u 
URL �t 0 taburl tabURL
�s 
pcnt
�r 
bool
�q .coreclosnull���     obj 
�p 
bTab
�o 
pURL
�n .ascrcmnt****      � ****��_jvE�O)��/j �-E�OjvE�O� �*�-E�O ��[��l kh  ��-E�O��,E�O o�[��l kh ��,E` O R�[��l kh �a ,a 	 _ �a ,a &	 �_ a & � *j UO_ �6FY h[OY��[OY��[OY�~UOa  �*�-E�O ��[��l kh  �a -E�O��,E�O y�[��l kh �a ,E` O_ j O R�[��l kh �a ,a 	 _ �a ,a &	 �_ a & � *j UO_ �6FY h[OY��[OY��[OY�rU ascr  ��ޭ