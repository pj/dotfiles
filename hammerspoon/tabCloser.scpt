FasdUAS 1.101.10   ��   ��    k             l     ����  r       	  J     ����   	 o      ���� 0 listtoclose listToClose��  ��     
  
 l    ����  r        n        2   ��
�� 
cpar  l    ����  I   �� ��
�� .rdwrread****        ****  4    	�� 
�� 
psxf  m       �   : / U s e r s / p a u l j o h n s o n / . b l o c k l i s t��  ��  ��    o      ���� 0 listtoclose listToClose��  ��        l    ����  r        J    ����    o      ���� 
0 closed  ��  ��        l     ��������  ��  ��        l     ��������  ��  ��         l      �� ! "��   !,&tell application "Safari"	set windowList to every window	repeat with theWindow in windowList		set tabList to every tab in theWindow		set tabList to reverse of tabList		repeat with t in tabList			set tabURL to URL of t			repeat with blockedURL in listToClose				if contents of blockedURL is not "" and tabURL contains (contents of blockedURL) and tabURL is not in closed then					# log tabURL					# log t					# log blockedURL					tell t to close					set end of closed to tabURL				end if			end repeat		end repeat	end repeatend tell    " � # #L  t e l l   a p p l i c a t i o n   " S a f a r i "  	 s e t   w i n d o w L i s t   t o   e v e r y   w i n d o w  	 r e p e a t   w i t h   t h e W i n d o w   i n   w i n d o w L i s t  	 	 s e t   t a b L i s t   t o   e v e r y   t a b   i n   t h e W i n d o w  	 	 s e t   t a b L i s t   t o   r e v e r s e   o f   t a b L i s t  	 	 r e p e a t   w i t h   t   i n   t a b L i s t  	 	 	 s e t   t a b U R L   t o   U R L   o f   t  	 	 	 r e p e a t   w i t h   b l o c k e d U R L   i n   l i s t T o C l o s e  	 	 	 	 i f   c o n t e n t s   o f   b l o c k e d U R L   i s   n o t   " "   a n d   t a b U R L   c o n t a i n s   ( c o n t e n t s   o f   b l o c k e d U R L )   a n d   t a b U R L   i s   n o t   i n   c l o s e d   t h e n  	 	 	 	 	 #   l o g   t a b U R L  	 	 	 	 	 #   l o g   t  	 	 	 	 	 #   l o g   b l o c k e d U R L  	 	 	 	 	 t e l l   t   t o   c l o s e  	 	 	 	 	 s e t   e n d   o f   c l o s e d   t o   t a b U R L  	 	 	 	 e n d   i f  	 	 	 e n d   r e p e a t  	 	 e n d   r e p e a t  	 e n d   r e p e a t  e n d   t e l l     $ % $ l     ��������  ��  ��   %  & ' & l     ��������  ��  ��   '  (�� ( l   � )���� ) O    � * + * k    � , ,  - . - r      / 0 / 2    ��
�� 
cwin 0 o      ���� 0 
windowlist 
windowList .  1�� 1 X   ! � 2�� 3 2 k   1 � 4 4  5 6 5 r   1 6 7 8 7 n  1 4 9 : 9 2   2 4��
�� 
CrTb : o   1 2���� 0 	thewindow 	theWindow 8 o      ���� 0 tablist tabList 6  ; < ; r   7 < = > = n   7 : ? @ ? 1   8 :��
�� 
rvse @ o   7 8���� 0 tablist tabList > o      ���� 0 tablist tabList <  A�� A X   = � B�� C B k   M � D D  E F E r   M T G H G n   M P I J I 1   N P��
�� 
URL  J o   M N���� 0 t   H o      ���� 0 taburl tabURL F  K�� K X   U � L�� M L Z   e � N O���� N F   e � P Q P F   e ~ R S R >  e n T U T n   e j V W V 1   f j��
�� 
pcnt W o   e f���� 0 
blockedurl 
blockedURL U m   j m X X � Y Y   S E   q z Z [ Z o   q t���� 0 taburl tabURL [ l  t y \���� \ n   t y ] ^ ] 1   u y��
�� 
pcnt ^ o   t u���� 0 
blockedurl 
blockedURL��  ��   Q H   � � _ _ E  � � ` a ` o   � ����� 
0 closed   a o   � ����� 0 taburl tabURL O k   � � b b  c d c O  � � e f e I  � �������
�� .coreclosnull���     obj ��  ��   f o   � ����� 0 t   d  g�� g r   � � h i h o   � ����� 0 taburl tabURL i n       j k j  ;   � � k o   � ����� 
0 closed  ��  ��  ��  �� 0 
blockedurl 
blockedURL M o   X Y���� 0 listtoclose listToClose��  �� 0 t   C o   @ A���� 0 tablist tabList��  �� 0 	thewindow 	theWindow 3 o   $ %���� 0 
windowlist 
windowList��   + m     l l�                                                                                  rimZ  alis    >  Macintosh HD               �3�BD ����Google Chrome.app                                              ����ީ�K        ����  
 cu             Applications  !/:Applications:Google Chrome.app/   $  G o o g l e   C h r o m e . a p p    M a c i n t o s h   H D  Applications/Google Chrome.app  / ��  ��  ��  ��       
�� m n o p q r s������   m ����������������
�� .aevtoappnull  �   � ****�� 0 listtoclose listToClose�� 
0 closed  �� 0 
windowlist 
windowList�� 0 tablist tabList�� 0 taburl tabURL��  ��   n �� t���� u v��
�� .aevtoappnull  �   � **** t k     � w w   x x  
 y y   z z  (����  ��  ��   u �������� 0 	thewindow 	theWindow�� 0 t  �� 0 
blockedurl 
blockedURL v ���� ������ l���������������������� X������ 0 listtoclose listToClose
�� 
psxf
�� .rdwrread****        ****
�� 
cpar�� 
0 closed  
�� 
cwin�� 0 
windowlist 
windowList
�� 
kocl
�� 
cobj
�� .corecnte****       ****
�� 
CrTb�� 0 tablist tabList
�� 
rvse
�� 
URL �� 0 taburl tabURL
�� 
pcnt
�� 
bool
�� .coreclosnull���     obj �� �jvE�O)��/j �-E�OjvE�O� �*�-E�O ��[��l kh  ��-E�O��,E�O o�[��l kh ��,E` O R�[��l kh �a ,a 	 _ �a ,a &	 �_ a & � *j UO_ �6FY h[OY��[OY��[OY�~U o �� {�� = { @  | } ~  � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � ������� | � � �  w w w . r e d d i t . c o m } � � �  r i b b o n f a r m . c o m ~ � � �  t w i t t e r . c o m  � � �  w w w . t w i t t e r . c o m � � � �  a p i . t w i t t e r . c o m � � � � $ m o b i l e . t w i t t e r . c o m � � � �  u n z . c o m � � � � , w w w . n a t i o n a l r e v i e w . c o m � � � � $ n a t i o n a l r e v i e w . c o m � � � �  r e d d i t . c o m � � � �  n p . r e d d i t . c o m � � � �  s a l o n . c o m � � � �  w w w . s a l o n . c o m � � � �  m e t a f i l t e r . c o m � � � �  t h e a t l a n t i c . c o m � � � � & w w w . t h e a t l a n t i c . c o m � � � � ( n e w s . y c o m b i n a t o r . c o m � � � �  p r o s p e c t . o r g � � � �  a r s t e c h n i c a . c o m � � � � " w w w . p i t c h f o r k . c o m � � � �  p i t c h f o r k . c o m � � � �  e c o n o m i s t . c o m � � � � " w w w . e c o n o m i s t . c o m � � � �  w w w . s t u f f . c o . n z � � � �  s t u f f . c o . n z � � � � 6 t h e a m e r i c a n c o n s e r v a t i v e . c o m � � � � > w w w . t h e a m e r i c a n c o n s e r v a t i v e . c o m � � � �  f a c e b o o k . c o m � � � �   w w w . f a c e b o o k . c o m � � � �  n y t i m e s . c o m � � � � , m a r g i n a l r e v o l u t i o n . c o m � � � �  f e e d l y . c o m � � � �  t e c h c r u n c h . c o m � � � � $ s l a t e s t a r c o d e x . c o m � � � � 4 a m e r i c a n a f f a i r s j o u r n a l . o r g � � � �  q u i l l e t t e . c o m � � � �  j a c o b i t e m a g . c o m � � � � * g r e y e n l i g h t e n m e n t . c o m � � � �  n y t i m e s . c o m � � � �  w w w . n y t i m e s . c o m � � � � ( w o r l d o f s o l i t a i r e . c o m � � � �  y o u t u b e . c o m � � � �  w w w . y o u t u b e . c o m � � � � 6 s c h o l a r s - s t a g e . b l o g s p o t . c o m � � � �  o l d . r e d d i t . c o m � � � �  d a m a g e m a g . c o m � � � �  u n h e r d . c o m � � � �   p a l l a d i u m m a g . c o m � � � �  s a m k r i s s . c o m � � � �  n z h e r a l d . c o . n z � � � � $ w w w . n z h e r a l d . c o . n z � � � �  c n n . c o m � � � �  b b c . c o m � � � �  w w w . b b c . c o m � � � �  t h e g u a r d i a n . c o m � � � � & w w w . t h e g u a r d i a n . c o m � � � �  e d i t i o n . c n n . c o m � � � �  i n s t a g r a m . c o m � � � �  s l o w b o r i n g . c o m � � � � . n o a h p i n i o n . s u b s t a c k . c o m � � � �  ��  ��  ��   p �� ���  �   ������������������������������ � � � � 0 h t t p s : / / t w i t t e r . c o m / h o m e��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  �   q �~ ��~  �   � � � � �  � �  l�} ��|
�} 
cwin � �    1 4 9 3 6 8 7 8 0
�| kfrmID   �   l�{�z
�{ 
cwin �  1 4 9 3 6 8 8 2 5
�z kfrmID   �   l�y�x
�y 
cwin �  1 4 9 3 6 8 7 6 3
�x kfrmID   �   l�w�v
�w 
cwin �		  1 4 9 3 6 8 7 4 3
�v kfrmID   r �u
�u 
    �t�s  l�r�q
�r 
cwin �  1 4 9 3 6 8 7 4 3
�q kfrmID  
�t 
CrTb �  1 4 9 3 6 8 7 6 0
�s kfrmID    �p�o  l�n�m
�n 
cwin �  1 4 9 3 6 8 7 4 3
�m kfrmID  
�p 
CrTb �  1 4 9 3 6 8 7 5 7
�o kfrmID    �l�k  l�j �i
�j 
cwin  �!!  1 4 9 3 6 8 7 4 3
�i kfrmID  
�l 
CrTb �""  1 4 9 3 6 8 7 5 4
�k kfrmID   ## $�h%�g$  l�f&�e
�f 
cwin& �''  1 4 9 3 6 8 7 4 3
�e kfrmID  
�h 
CrTb% �((  1 4 9 3 6 8 7 5 1
�g kfrmID   )) *�d+�c*  l�b,�a
�b 
cwin, �--  1 4 9 3 6 8 7 4 3
�a kfrmID  
�d 
CrTb+ �..  1 4 9 3 6 8 7 4 8
�c kfrmID   // 0�`1�_0  l�^2�]
�^ 
cwin2 �33  1 4 9 3 6 8 7 4 3
�] kfrmID  
�` 
CrTb1 �44  1 4 9 3 6 8 7 4 4
�_ kfrmID   s �55� h t t p s : / / i d . t r i m b l e . c o m / u i / s i g n _ i n . h t m l ? s t a t e = e y J h b G c i O i J S U z I 1 N i I s I m t p Z C I 6 I j E i L C J 0 e X A i O i J K V 1 Q i f Q . e y J v Y X V 0 a F 9 w Y X J h b W V 0 Z X J z I j p 7 I m N s a W V u d F 9 p Z C I 6 I m M 5 M T N h O T B j L T R k Y 2 Y t N G F m Y i 1 i M 2 R i L T Y z N 2 J l M z c 3 N D Z i Z i I s I n J l Z G l y Z W N 0 X 3 V y a S I 6 I m h 0 d H B z O i 8 v b G 9 n a W 4 u c 2 t l d G N o d X A u Y 2 9 t L 2 x v Z 2 l u L 3 R y a W 1 i b G V p Z C 9 j Y W x s Y m F j a y I s I n J l c 3 B v b n N l X 3 R 5 c G U i O i J j b 2 R l I i w i c 2 N v c G U i O i J v c G V u a W Q g c 2 t l d G N o d X A t b G 9 n a W 4 t c H J v Z C 1 W M i I s I n N 0 Y X R l I j o i U V h W M G F F d G x l U 0 F 6 T j J K b F k y T m l a U z A w W l d R N E x U U m h Z V E l 0 T 0 d J e k 5 p M D F Z V 1 E 1 T n p k a k 5 E W X p O M l V f I n 0 s I m V 4 d H J h X 3 B h c m F t Z X R l c n M i O n s i b G F u Z y I 6 I m V u I n 0 s I m l u d G V y b m F s X 3 B h c m F t Z X R l c n M i O n t 9 f Q . i Q r a S - U D 2 8 1 4 Q G K E j 2 s y J X 4 - K R m 0 t A U t 9 Q 6 L p 5 8 3 n X 6 i K t c B G f y P t L 6 U S A 8 w O Q Y e a H N V l 1 x 4 2 7 Z K k y V s O c D 1 O k a 3 m w 5 3 7 G 3 v X 6 l l D 1 N Z l e e V 3 - d E y j Q S b m V u u A A f 7 G x e f A n y y K x M q X e u n r V I P e 5 E O U O n x n i x H r X z 7 K z U T z 7 _ w F w _ b s g M T R F S 8 - Q V u h Q S y Y C I P x D v w T _ 4 P A Q r g f B o w e G 4 R K i H c C T C O r o 4 d L 2 R N M 0 O f a 3 u W Z u O r q T n 2 B s H 7 4 U A u 1 9 v 9 l Q T r 0 8 Z r I D b u v k B K C x K J 5 O S g C 2 k B 6 P G 7 q z O X q w A v 9 1 x X q k 7 A Y C 1 Y U m Y U D D Y W r p s z 2 V F H C M y _ A - e 8 M F G 6 8 K 6 G Q��  ��  ascr  ��ޭ