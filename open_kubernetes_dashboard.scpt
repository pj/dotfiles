FasdUAS 1.101.10   ��   ��    k             l     ����  r       	  m      
 
 �    ~ / . k u b e / k 3 s 	 o      ���� 0 
kubeconfig 
KUBECONFIG��  ��        l     ��������  ��  ��        l    ����  r        m       �  N # ! / b i n / b a s h 
 P A T H = $ P A T H : / o p t / h o m e b r e w / b i n : / u s r / l o c a l / b i n 
 c d   ~ / P r o g r a m m i n g / l a z y _ c l o u d 
 
 e c h o   ' a h e r ' 
 d i r e n v   e x e c   .   k u b e c t l   - n   k u b e r n e t e s - d a s h b o a r d   c r e a t e   t o k e n   a d m i n - u s e r 
  o      ���� 0 shellscript shellScript��  ��        l     ��������  ��  ��        l    ����  r        b        l    ����  I   ��   
�� .earsffdralis        afdr  m    	��
�� afdmtemp   �� !��
�� 
rtyp ! m   
 ��
�� 
TEXT��  ��  ��    m     " " � # #  m y S c r i p t . s h  o      ���� 0 
scriptfile 
scriptFile��  ��     $ % $ l    &���� & r     ' ( ' I   �� ) *
�� .rdwropenshor       file ) o    ���� 0 
scriptfile 
scriptFile * �� +��
�� 
perm + m    ��
�� boovtrue��   ( o      ���� 0 fileref fileRef��  ��   %  , - , l   % .���� . I   %�� / 0
�� .rdwrwritnull���     **** / o    ���� 0 shellscript shellScript 0 �� 1��
�� 
refn 1 o     !���� 0 fileref fileRef��  ��  ��   -  2 3 2 l  & + 4���� 4 I  & +�� 5��
�� .rdwrclosnull���     **** 5 o   & '���� 0 fileref fileRef��  ��  ��   3  6 7 6 l     ��������  ��  ��   7  8 9 8 l     �� : ;��   : ' ! Make the shell script executable    ; � < < B   M a k e   t h e   s h e l l   s c r i p t   e x e c u t a b l e 9  = > = l  , = ?���� ? I  , =�� @��
�� .sysoexecTEXT���     TEXT @ b   , 9 A B A m   , / C C � D D  c h m o d   + x   B n   / 8 E F E 1   4 8��
�� 
strq F n   / 4 G H G 1   0 4��
�� 
psxp H o   / 0���� 0 
scriptfile 
scriptFile��  ��  ��   >  I J I l     ��������  ��  ��   J  K L K l     �� M N��   M : 4 Run the shell script with the environment variables    N � O O h   R u n   t h e   s h e l l   s c r i p t   w i t h   t h e   e n v i r o n m e n t   v a r i a b l e s L  P Q P l  > S R���� R r   > S S T S I  > O�� U��
�� .sysoexecTEXT���     TEXT U b   > K V W V m   > A X X � Y Y  s o u r c e   W n   A J Z [ Z 1   F J��
�� 
strq [ n   A F \ ] \ 1   B F��
�� 
psxp ] o   A B���� 0 
scriptfile 
scriptFile��   T o      ���� 	0 token  ��  ��   Q  ^ _ ^ l     ��������  ��  ��   _  ` a ` l     �� b c��   b "  Split the string into lines    c � d d 8   S p l i t   t h e   s t r i n g   i n t o   l i n e s a  e f e l  T _ g���� g r   T _ h i h n   T [ j k j 2  W [��
�� 
cpar k o   T W���� 	0 token   i o      ���� 0 
tokenlines 
tokenLines��  ��   f  l m l l     ��������  ��  ��   m  n o n l     �� p q��   p   Get the last line    q � r r $   G e t   t h e   l a s t   l i n e o  s t s l  ` l u���� u r   ` l v w v n   ` h x y x 4  c h�� z
�� 
cobj z m   f g������ y o   ` c���� 0 
tokenlines 
tokenLines w o      ���� 	0 token  ��  ��   t  { | { l     ��������  ��  ��   |  } ~ } l     ��  ���    7 1 Clean up: Delete the temporary shell script file    � � � � b   C l e a n   u p :   D e l e t e   t h e   t e m p o r a r y   s h e l l   s c r i p t   f i l e ~  � � � l  m ~ ����� � I  m ~�� ���
�� .sysoexecTEXT���     TEXT � b   m z � � � m   m p � � � � �  r m   - f   � n   p y � � � 1   u y��
�� 
strq � n   p u � � � 1   q u��
�� 
psxp � o   p q���� 0 
scriptfile 
scriptFile��  ��  ��   �  � � � l     ��������  ��  ��   �  � � � l   � ����� � r    � � � � m    � � � � � � � h t t p : / / l o c a l h o s t : 8 0 0 1 / a p i / v 1 / n a m e s p a c e s / k u b e r n e t e s - d a s h b o a r d / s e r v i c e s / h t t p s : k u b e r n e t e s - d a s h b o a r d : / p r o x y / # / l o g i n � o      ���� 0 	targeturl 	targetURL��  ��   �  � � � l     ��������  ��  ��   �  � � � l     �� � ���   � 6 0 Tell Google Chrome to open the URL in a new tab    � � � � `   T e l l   G o o g l e   C h r o m e   t o   o p e n   t h e   U R L   i n   a   n e w   t a b �  � � � l  � � ����� � O   � � � � � k   � � � �  � � � I  � �������
�� .miscactvnull��� ��� null��  ��   �  ��� � O   � � � � � r   � � � � � I  � ����� �
�� .corecrel****      � null��   � �� � �
�� 
kocl � m   � ���
�� 
CrTb � �� � �
�� 
insh � n   � � � � � 9   � ���
�� 
insl � l  � � ����� � e   � � � � 1   � ���
�� 
acTa��  ��   � �� ���
�� 
prdt � K   � � � � �� ���
�� 
URL  � o   � ����� 0 	targeturl 	targetURL��  ��   � o      ���� 0 newtab newTab � 4  � ��� �
�� 
cwin � m   � ��� ��   � m   � � � ��                                                                                  rimZ  alis    >  Macintosh HD               �3�BD ����Google Chrome.app                                              ����ީ�K        ����  
 cu             Applications  !/:Applications:Google Chrome.app/   $  G o o g l e   C h r o m e . a p p    M a c i n t o s h   H D  Applications/Google Chrome.app  / ��  ��  ��   �  � � � l     �~�}�|�~  �}  �|   �  � � � l     �{�z�y�{  �z  �y   �  � � � l     �x � ��x   � F @ Wait for the new tab to load (you may need to adjust the delay)    � � � � �   W a i t   f o r   t h e   n e w   t a b   t o   l o a d   ( y o u   m a y   n e e d   t o   a d j u s t   t h e   d e l a y ) �  � � � l  � � ��w�v � I  � ��u ��t
�u .sysodelanull��� ��� nmbr � m   � ��s�s �t  �w  �v   �  � � � l     �r�q�p�r  �q  �p   �  � � � l  � � ��o�n � I  � ��m ��l
�m .JonspClpnull���     **** � o   � ��k�k 	0 token  �l  �o  �n   �  � � � l     �j�i�h�j  �i  �h   �  � � � l  � � ��g�f � r   � � � � � b   � � � � � b   � � � � � m   � � � � � � � 
 d o c u m e n t . q u e r y S e l e c t o r ( ' # m a t - r a d i o - 2 - i n p u t ' ) . c l i c k ( ) ; 
 v a r   t o k e n B o x   =   d o c u m e n t . g e t E l e m e n t B y I d ( ' t o k e n ' ) ; 
 t o k e n B o x . c l i c k ( ) ; 
 / * 
 t o k e n B o x . v a l u e   =   ' � o   � ��e�e 	0 token   � m   � � � � � � � � ' ; 
 v a r   i n p u t E v e n t   =   n e w   E v e n t ( ' i n p u t ' ,   { 
     b u b b l e s :   t r u e , 
     c a n c e l a b l e :   t r u e , 
 } ) ; 
 
 t o k e n B o x . d i s p a t c h E v e n t ( i n p u t E v e n t ) ; 
 * / 
 � o      �d�d  0 tokensetscript tokenSetScript�g  �f   �  � � � l  � ��c�b � O   � � � � O   �  � � � k   � � � �  � � � l  � ��a � ��a   � c ] Replace 'your-checkbox-selector' with the appropriate CSS selector for your checkbox element    � � � � �   R e p l a c e   ' y o u r - c h e c k b o x - s e l e c t o r '   w i t h   t h e   a p p r o p r i a t e   C S S   s e l e c t o r   f o r   y o u r   c h e c k b o x   e l e m e n t �  � � � I  � ��`�_ �
�` .CrSuExJanull���     obj �_   � �^ ��]
�^ 
JvSc � o   � ��\�\  0 tokensetscript tokenSetScript�]   �  ��[ � l  � ��Z�Y�X�Z  �Y  �X  �[   � o   � ��W�W 0 newtab newTab � m   � � � ��                                                                                  rimZ  alis    >  Macintosh HD               �3�BD ����Google Chrome.app                                              ����ީ�K        ����  
 cu             Applications  !/:Applications:Google Chrome.app/   $  G o o g l e   C h r o m e . a p p    M a c i n t o s h   H D  Applications/Google Chrome.app  / ��  �c  �b   �  � � � l     �V�U�T�V  �U  �T   �  � � � l  ��S�R � O  � � � I �Q ��P
�Q .prcskprsnull���     ctxt � l  ��O�N � I �M�L �
�M .JonsgClp****    ��� null�L   � �K ��J
�K 
rtyp � m  
�I
�I 
ctxt�J  �O  �N  �P   � m   � ��                                                                                  sevs  alis    \  Macintosh HD               �3�BD ����System Events.app                                              �����3�        ����  
 cu             CoreServices  0/:System:Library:CoreServices:System Events.app/  $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��  �S  �R   �  � � � l     �H�G�F�H  �G  �F   �  � � � l  ��E�D � I �C ��B
�C .sysodelanull��� ��� nmbr � m  �A�A �B  �E  �D   �    l     �@�?�>�@  �?  �>   �= l 8�<�; O  8 O  #7 k  )6 	
	 l ))�:�:   c ] Replace 'your-checkbox-selector' with the appropriate CSS selector for your checkbox element    � �   R e p l a c e   ' y o u r - c h e c k b o x - s e l e c t o r '   w i t h   t h e   a p p r o p r i a t e   C S S   s e l e c t o r   f o r   y o u r   c h e c k b o x   e l e m e n t
  I )4�9�8
�9 .CrSuExJanull���     obj �8   �7�6
�7 
JvSc m  -0 � � d o c u m e n t . q u e r y S e l e c t o r ( ' b u t t o n [ t y p e = s u b m i t ] ' ) . f o c u s ( ) ;   d o c u m e n t . q u e r y S e l e c t o r ( ' b u t t o n [ t y p e = s u b m i t ] ' ) . c l i c k ( )�6   �5 l 55�4�3�2�4  �3  �2  �5   o  #&�1�1 0 newtab newTab m   �                                                                                  rimZ  alis    >  Macintosh HD               �3�BD ����Google Chrome.app                                              ����ީ�K        ����  
 cu             Applications  !/:Applications:Google Chrome.app/   $  G o o g l e   C h r o m e . a p p    M a c i n t o s h   H D  Applications/Google Chrome.app  / ��  �<  �;  �=       �0 
 �/ ��.�-�,�+�*�)�0   �(�'�&�%�$�#�"�!� �������
�( .aevtoappnull  �   � ****�' 0 
kubeconfig 
KUBECONFIG�& 0 shellscript shellScript�% 0 
scriptfile 
scriptFile�$ 0 fileref fileRef�# 	0 token  �" 0 
tokenlines 
tokenLines�! 0 	targeturl 	targetURL�  0 newtab newTab�  0 tokensetscript tokenSetScript�  �  �  �  �  �   ����
� .aevtoappnull  �   � **** k    8    !!  ""  ##  $$$  ,%%  2&&  =''  P((  e))  s**  �++  �,,  �--  �..  �//  �00  �11  �22  �33 ��  �  �     5 
� ����� "����
�	�� C��� X����  � ��� ����������������������������� � ������� �������� 0 
kubeconfig 
KUBECONFIG� 0 shellscript shellScript
� afdmtemp
� 
rtyp
� 
TEXT
� .earsffdralis        afdr� 0 
scriptfile 
scriptFile
� 
perm
� .rdwropenshor       file�
 0 fileref fileRef
�	 
refn
� .rdwrwritnull���     ****
� .rdwrclosnull���     ****
� 
psxp
� 
strq
� .sysoexecTEXT���     TEXT� 	0 token  
� 
cpar� 0 
tokenlines 
tokenLines
�  
cobj�� 0 	targeturl 	targetURL
�� .miscactvnull��� ��� null
�� 
cwin
�� 
kocl
�� 
CrTb
�� 
insh
�� 
acTa
�� 
insl
�� 
prdt
�� 
URL �� 
�� .corecrel****      � null�� 0 newtab newTab
�� .sysodelanull��� ��� nmbr
�� .JonspClpnull���     ****��  0 tokensetscript tokenSetScript
�� 
JvSc
�� .CrSuExJanull���     obj 
�� 
ctxt
�� .JonsgClp****    ��� null
�� .prcskprsnull���     ctxt�9�E�O�E�O���l �%E�O��el E�O���l O�j Oa �a ,a ,%j Oa �a ,a ,%j E` O_ a -E` O_ a i/E` Oa �a ,a ,%j Oa E` Oa  ;*j O*a k/ +*a a  a !*a ",Ea #4a $a %_ la & 'E` (UUOkj )O_ j *Oa +_ %a ,%E` -Oa  _ ( *a ._ -l /OPUUOa 0 *�a 1l 2j 3UOkj )Oa  _ ( *a .a 4l /OPUU �44 � M a c i n t o s h   H D : p r i v a t e : v a r : f o l d e r s : 3 4 : 7 y g 1 w z m j 5 2 s d 3 j 0 g k f x 5 s q 9 h 0 0 0 0 g n : T : T e m p o r a r y I t e m s : m y S c r i p t . s h�/ �552 e y J h b G c i O i J S U z I 1 N i I s I m t p Z C I 6 I m F Y a T B H N X N k Y 2 F t U l F L T 2 4 y N T N X a j l C S 3 V m b k h o T V B 5 d G Z 3 Z E l U S z l u V z A i f Q . e y J h d W Q i O l s i a H R 0 c H M 6 L y 9 r d W J l c m 5 l d G V z L m R l Z m F 1 b H Q u c 3 Z j L m N s d X N 0 Z X I u b G 9 j Y W w i L C J r M 3 M i X S w i Z X h w I j o x N j k 0 M z k 2 M D Q 0 L C J p Y X Q i O j E 2 O T Q z O T I 0 N D Q s I m l z c y I 6 I m h 0 d H B z O i 8 v a 3 V i Z X J u Z X R l c y 5 k Z W Z h d W x 0 L n N 2 Y y 5 j b H V z d G V y L m x v Y 2 F s I i w i a 3 V i Z X J u Z X R l c y 5 p b y I 6 e y J u Y W 1 l c 3 B h Y 2 U i O i J r d W J l c m 5 l d G V z L W R h c 2 h i b 2 F y Z C I s I n N l c n Z p Y 2 V h Y 2 N v d W 5 0 I j p 7 I m 5 h b W U i O i J h Z G 1 p b i 1 1 c 2 V y I i w i d W l k I j o i Y 2 M 2 M G M 0 N T A t Y m V j Y y 0 0 Z T J i L W E 1 Z W U t M m J k N m U 2 Y m M z Z j J l I n 1 9 L C J u Y m Y i O j E 2 O T Q z O T I 0 N D Q s I n N 1 Y i I 6 I n N 5 c 3 R l b T p z Z X J 2 a W N l Y W N j b 3 V u d D p r d W J l c m 5 l d G V z L W R h c 2 h i b 2 F y Z D p h Z G 1 p b i 1 1 c 2 V y I n 0 . r z U s F I l h k G e E j B E I 4 d K d G 9 S M o 9 I G G t v F V Q c 7 q I h 4 5 l 3 Q 5 r C 8 Y l q 5 a P 9 N H A j 9 a n _ 1 5 R H L q A C l h 8 _ S f b x y 4 C O l e - h c x 3 o 3 v f P 3 z w q Q W 9 R 5 J 9 e 1 H k 3 H j H Y p 2 h F G T v E V R Z w - i f Z G R 1 7 _ 8 p S V 9 R l 9 Z t q N k R m R J I Y R F E q e g f u M 2 u L l H m f 3 f 6 R g b x B 2 D E b L K T n X v P k x v D H Q I Y A 9 F S T b R W Q P J 7 8 X Y 7 Y T G 2 x X P X x f p R Q t O D m e u K Z x P 4 h M _ 7 O 1 S e 2 M j Z x k c f 8 t 0 6 o l P T k Y Y n x v G P j Z o D t z H M 9 V G d s j Q _ M R N Q m q h I h q J b G D u g X J O i A 5 r D A l 8 w I N H P m I F r y u g m - S X t t 6 L W i c M 3 e O I g ��6�� 6  7����������������������������7 �88  a h e r��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��   99 :��;��:  ���<��
�� 
cwin< �==  1 4 9 3 6 8 8 2 5
�� kfrmID  
�� 
CrTb; �>>  1 4 9 3 6 9 3 9 7
�� kfrmID   �??	D 
 d o c u m e n t . q u e r y S e l e c t o r ( ' # m a t - r a d i o - 2 - i n p u t ' ) . c l i c k ( ) ; 
 v a r   t o k e n B o x   =   d o c u m e n t . g e t E l e m e n t B y I d ( ' t o k e n ' ) ; 
 t o k e n B o x . c l i c k ( ) ; 
 / * 
 t o k e n B o x . v a l u e   =   ' e y J h b G c i O i J S U z I 1 N i I s I m t p Z C I 6 I m F Y a T B H N X N k Y 2 F t U l F L T 2 4 y N T N X a j l C S 3 V m b k h o T V B 5 d G Z 3 Z E l U S z l u V z A i f Q . e y J h d W Q i O l s i a H R 0 c H M 6 L y 9 r d W J l c m 5 l d G V z L m R l Z m F 1 b H Q u c 3 Z j L m N s d X N 0 Z X I u b G 9 j Y W w i L C J r M 3 M i X S w i Z X h w I j o x N j k 0 M z k 2 M D Q 0 L C J p Y X Q i O j E 2 O T Q z O T I 0 N D Q s I m l z c y I 6 I m h 0 d H B z O i 8 v a 3 V i Z X J u Z X R l c y 5 k Z W Z h d W x 0 L n N 2 Y y 5 j b H V z d G V y L m x v Y 2 F s I i w i a 3 V i Z X J u Z X R l c y 5 p b y I 6 e y J u Y W 1 l c 3 B h Y 2 U i O i J r d W J l c m 5 l d G V z L W R h c 2 h i b 2 F y Z C I s I n N l c n Z p Y 2 V h Y 2 N v d W 5 0 I j p 7 I m 5 h b W U i O i J h Z G 1 p b i 1 1 c 2 V y I i w i d W l k I j o i Y 2 M 2 M G M 0 N T A t Y m V j Y y 0 0 Z T J i L W E 1 Z W U t M m J k N m U 2 Y m M z Z j J l I n 1 9 L C J u Y m Y i O j E 2 O T Q z O T I 0 N D Q s I n N 1 Y i I 6 I n N 5 c 3 R l b T p z Z X J 2 a W N l Y W N j b 3 V u d D p r d W J l c m 5 l d G V z L W R h c 2 h i b 2 F y Z D p h Z G 1 p b i 1 1 c 2 V y I n 0 . r z U s F I l h k G e E j B E I 4 d K d G 9 S M o 9 I G G t v F V Q c 7 q I h 4 5 l 3 Q 5 r C 8 Y l q 5 a P 9 N H A j 9 a n _ 1 5 R H L q A C l h 8 _ S f b x y 4 C O l e - h c x 3 o 3 v f P 3 z w q Q W 9 R 5 J 9 e 1 H k 3 H j H Y p 2 h F G T v E V R Z w - i f Z G R 1 7 _ 8 p S V 9 R l 9 Z t q N k R m R J I Y R F E q e g f u M 2 u L l H m f 3 f 6 R g b x B 2 D E b L K T n X v P k x v D H Q I Y A 9 F S T b R W Q P J 7 8 X Y 7 Y T G 2 x X P X x f p R Q t O D m e u K Z x P 4 h M _ 7 O 1 S e 2 M j Z x k c f 8 t 0 6 o l P T k Y Y n x v G P j Z o D t z H M 9 V G d s j Q _ M R N Q m q h I h q J b G D u g X J O i A 5 r D A l 8 w I N H P m I F r y u g m - S X t t 6 L W i c M 3 e O I g ' ; 
 v a r   i n p u t E v e n t   =   n e w   E v e n t ( ' i n p u t ' ,   { 
     b u b b l e s :   t r u e , 
     c a n c e l a b l e :   t r u e , 
 } ) ; 
 
 t o k e n B o x . d i s p a t c h E v e n t ( i n p u t E v e n t ) ; 
 * / 
�.  �-  �,  �+  �*  �)   ascr  ��ޭ