" dsfcg.vim -- Doxygen style function comment generator
" 
" version : 0.1.7
" author : ampmmn(htmnymgw <delete>@<delete> gmail.com)
" url    : http://d.hatena.ne.jp/ampmmn
"
" ----
" history
"	 0.1.7		2023-06-24	Replace python with python3.
"	 0.1.6		2008-10-29	Bugfix for alignment output.
"	 0.1.5		2008-09-24	Bugfix for keymapping.
"	 0.1.4		2008-09-05	support PHP,Python,Perl,Ruby,JavaScript
"	 0.1.3		2008-09-02	Add brief comment input. New support K&R style.
"	 0.1.2		2008-08-31	Implement argument indent alignment.
"	 0.1.1		2008-08-29	1st release.
" ----
"
if exists('loaded_dsfcg') || &cp
  finish
endif
let loaded_dsfcg=1

if !has('python3')
	echo "dsfcg.vim requires +python3 or +python3/dyn"
	finish
endif

" �ѿ����������Ƥ��ʤ������������
function! s:declareValue(name, value)
	if !exists('g:dsfcg_'. a:name)
		exe 'let g:dsfcg_'.a:name.'=a:value'
	endif
endfunction

" Global options.

""""""" �ƥե����륿���פΥǥե��������
""""""" (�ե����륿�����Ѥ������ͤ����ꤵ��Ƥ��ʤ���硢�������꤬���Ѥ���ޤ�)

" �ؿ���������Ƭ���ν�
call s:declareValue('format_header', '/**')
" �ؿ��������������ν�
call s:declareValue('format_footer', '**/')
" �����ȳ��ϡ���λ��ɽ���������(�ꥹ�Ȥǵ���)
call s:declareValue('comment_words', [ ['/*', '*/'], ['//', '\n'] ])

" �ؿ���������Ǥν��Ͻ��
" ���Ȥ��С�"DRA"�ȵ��Ҥ������ϡ��ؿ�����,�����,�����ꥹ�� �Ȥ��������
" �����Ȥ��������ޤ���
" �����ȿ�����������"D"�Ԥϡ�g:dsfcg_default_descriptionN(1��)�������ͤ�
" ���Ϥ��ޤ���
" �ؿ������Ԥ�ʣ���Խ��Ϥ�����ˤϡ�"DDRA"�Τ褦�˽��Ϥ���Կ�����'D'�򵭽�
" ����g:dsfcg_default_description1="...",g:dsfcg_default_description2="..."��
" �褦�˽��ϹԿ�ʬ�������귿ʸ�����ꤷ�ޤ���
"
" D: Description R: Return value A: Argument
call s:declareValue('element_order', 'DRA')
" �ؿ����������Ϥ��뤫?
" (C/C++�ʳ��Ϥ����ȵ�ǽ���ʤ��Τǡ�̵����)
call s:declareValue('is_alignment', 0)
call s:declareValue('is_alignment_cpp', 1)
call s:declareValue('is_alignment_c', 1)

" �桼������������
" defaultmsg�ϥ����ȿ����������Υ�å������Ǥ���"
call s:declareValue('user_keywords', { 
		\ 'defaultmsg' : "\tEnter description here.",
		\ 'date' : strftime("%Y-%m-%d"),
		\ })

" �ؿ������ȿ����������δؿ��������������귿ʸ
call s:declareValue('default_description1', "%defaultmsg")

" �����������ϥ����פ�ɽ�����
call s:declareValue('inout_types', [ "[in]", "[out]", "[in,out]" ])
" �����������ϥ����פ�ɽ�����
call s:declareValue('permission_tags', [ "@public", "@protected", "@private" ])

" �ؿ������ȿ����������Ρ����������Ԥν��Ͻ�
" %inout:�����ϥ����� %name:����̾ %description:����ʸ
call s:declareValue('template_argument', "\t@param%inout %name %description")
" ��¸�δؿ������Ȥ���Ϥ���ݤΡ����������Ԥ��̤��뤿�������ɽ���ѥ�����
call s:declareValue('regexp_argument', '.*?[\\@]param(.+?)\s+(.+?)\s+(.*)$')
" g:dsfcg_regexp_argument�Ǥ�����ɽ���ޥå��󥰤�Ԥä���̡�
" �ɤΥ��롼�פ����ɤ����Ǥ��б����뤫(,���ڤ�ǻ���)
call s:declareValue('escapetext_argument', "%inout,%name,%description")

" �ؿ������ȿ����������Ρ�����������Ԥν��Ͻ�
" %description:����ʸ
call s:declareValue('template_return', "\t@return %description")

" ��¸�δؿ������Ȥ���Ϥ���ݤΡ�����������Ԥ��̤��뤿�������ɽ���ѥ�����
call s:declareValue('regexp_return', '.*?[\\@]return\s*(.*)$')
" g:dsfcg_regexp_return�Ǥ�����ɽ���ޥå��󥰤�Ԥä���̡�
" �ɤΥ��롼�פ����ɤ����Ǥ��б����뤫(,���ڤ�ǻ���)
call s:declareValue('escapetext_return', "%description")

""""""" PHP�Ѥ�����
call s:declareValue('element_order_php', 'DPRA')
	" D: Description R: Return value A: Argument P:Permission
call s:declareValue('template_permission_php', "\t%permission")

""""""" JavaScript�Ѥ�����(�Ƥ��Ȥ�)
call s:declareValue('format_header_javascript', '/**')
call s:declareValue('format_footer_javascript', '*/')
call s:declareValue('template_argument_javascript', "\t@param {%type} %name %description")
call s:declareValue('regexp_argument_javascript', '.*?[\\@]param\s*?\{(\w*)\}\s*(.+?)(\s+(.*))?$')
call s:declareValue('escapetext_argument_javascript', "%type,%name,,%description")
call s:declareValue('template_return_javascript', "\t@return %description")
call s:declareValue('regexp_return_javascript', '.*?[\\@]return\s*(.*)$')


""""""" Perl�Ѥ�����
call s:declareValue('format_header_perl','')
call s:declareValue('format_footer_perl','')
call s:declareValue('comment_words_perl', [ ['#', '\n'] ])
call s:declareValue('template_argument_perl', "# @param %name %description")
call s:declareValue('regexp_argument_perl','.*?[\\@]param\s*?(.+?)(\s+(.*))?$')
call s:declareValue('escapetext_argument_perl',"%name,,%description")
call s:declareValue('template_return_perl', "# @return %description")
call s:declareValue('regexp_return_perl','.*?[\\@]return\s*(.*)$')
call s:declareValue('element_order_perl','DRA')
call s:declareValue('default_description1_perl', "## %defaultmsg")

""""""" Ruby�Ѥ�����
call s:declareValue('format_header_ruby','')
call s:declareValue('format_footer_ruby','')
call s:declareValue('comment_words_ruby', [ ['#', '\n'] ])
call s:declareValue('template_argument_ruby', "# @param %name %description")
call s:declareValue('regexp_argument_ruby','.*?[\\@]param\s*?(.+?)(\s+(.*))?$')
call s:declareValue('escapetext_argument_ruby',"%name,,%description")
call s:declareValue('template_return_ruby', "# @return %description")
call s:declareValue('regexp_return_ruby','.*?[\\@]return\s*(.*)$')
call s:declareValue('element_order_ruby','DRA')
call s:declareValue('default_description1_ruby', "## %defaultmsg")

""""""" Python�Ѥ�����
call s:declareValue('format_header_python','')
call s:declareValue('format_footer_python','')
call s:declareValue('comment_words_python', [ ['#', '\n'] ])
call s:declareValue('template_argument_python', "# @param %name %description")
call s:declareValue('regexp_argument_python','.*?[\\@]param\s*(\w+?)(\s+(.*))?$')
call s:declareValue('escapetext_argument_python',"%name,,%description")
call s:declareValue('template_return_python', "# @return %description")
call s:declareValue('regexp_return_python','.*?[\\@]return\s*(.*)$')
call s:declareValue('element_order_python','DRA')
call s:declareValue('default_description1_python', "## %defaultmsg")

" 'vmap m :<c-u>call DSMakeFunctionComment()<cr>'�Ȥ���
" �ǥե���ȤΥ����ޥåԥ󥰤�ͭ���ˤ��뤫
call s:declareValue('enable_mapping', 1)

" Functions.

function! s:makeComment()
	" ����ƥ����Ȥ����(�����Х��ѿ���ͳ��Python������¦���Ϥ�)
	let g:dsfcg_select=s:selected_text()
python3 << END_OF_PYTHON
################################################################################
import vim
import re

typeArg = 1
typeReturn = 2
typeOther = 3

typePublic = 0
typeProtected = 1
typePrivate = 2

typeInput  = 0
typeOutput = 1
typeInOut  = 2

# vim¦��������줿�ѿ������
# @return ����������(see :h python-eval)
# @param name     �ѿ�̾
# @param defValue �ǥե������
def getvim(name, defValue=''):
	ft = vim.eval('&ft')
	if ft != '' and vim.eval('exists("g:dsfcg_'+name+'_'+ft+'")') != '0':
		return vim.eval('g:dsfcg_' + name+'_'+ft)
	if vim.eval('exists("g:dsfcg_'+name+'")') != '0':
		return vim.eval('g:dsfcg_' + name)
	return defValue
# vim¦���ѿ�������
# @param values (name,value)��tuple
def setvim(*values):
	for (key, value) in values:
		if isinstance(value, int): value=str(value)
		elif isinstance(value, str): value="'"+value+"'"
		vim.command('let g:dsfcg_' + key + '=' + value)

# ʣ����replace��¹�
# @return �Ѵ���ʸ����
# @param data         �Ѵ��оݥƥ�����
# @param beforeAfters (before,after)��tuple
def replacem(data, *beforeAfters):
	for (before,after) in beforeAfters:
		data = data.replace(before,after)
	return data

# ����ʪ���饹
class StyleInfo:
	# line�ϰ�������Ԥ�?
	# @param line �ƥ�����(1��)
	def isArgumentLine(self, line):
		if hasattr(self, "_regpatArgument") == False:
			regexp = getvim('regexp_argument')
			if regexp == None: return False
			self._regpatArgument = re.compile(regexp)
		return self._regpatArgument.match(line) != None
	# line������ͻ���Ԥ�?
	def isReturnLine(self, line):
		if hasattr(self, "_regpatReturn") == False:
			regexp = getvim('regexp_return')
			if regexp == None: return False
			self._regpatReturn = re.compile(regexp)
		return self._regpatReturn.match(line) != None
	# �����Ե��Ҥβ���
	# ����ͤ�_regpatArgument���ؤ�����ɽ����ʬ�򤷤���̤�tuple���ޤ���None
	def parseArgument(self, line):
		if hasattr(self, "_regpatArgument") == False: return None
		try:    return self._regpatArgument.match(line).groups()
		except: return None
	# ����Ͳ��ϹԤβ���
	# ����ͤ�_regpatReturn���ؤ�����ɽ����ʬ�򤷤���̤�tuple���ޤ���None
	def parseReturn(self, line):
		if hasattr(self, "_regpatReturn") == False: return None
		try:    return self._regpatReturn.match(line).groups()
		except: return None
	# ���������������������ǽ��Ͻ�������(A or R or D)
	def getElementOrder(self):
		return getvim('element_order')
	## �ؿ�����ʸ�Υƥ�ץ졼��ʸ��������
	# @param index �Կ�����ǥå���(0��)
	###
	def getDescriptionTemplate(self,index):
		return getvim('default_description'+str(index))
	# ��̾���顢���������פ����(in|out|in,out)
	def getInOutType(self, typeName):
		types = getvim('inout_types')
		if 'const' in typeName: return types[typeInput]
		if '*' in typeName or '&' in typeName:
			return types[typeInOut]
		return types[typeInput]

	# ����ͤΥƥ�ץ졼�Ȥ����
	def getOutputReturnTemplate(self): return getvim('template_return')
	def getReturnEscapeText(self,index):
		try:    return getvim('escapetext_return').split(',')[index]
		except: return ''
	def getPermissionTemplate(self): return getvim('template_permission')
	# ��¸�Υ����Ⱦ��󤫤顢̾�������פ�������˴ؤ����������
	# @param commentInfo �����Ⱦ���
	# @param valName     ����̾
	def getArgumentInfo(self, commentInfo, valName):
		for item in commentInfo:
			elemType, elemData = item[0], item[1]
			if elemType != typeArg: continue
			n = self.getArgumentGroupIndex('%name')
			if n == -1: continue
			if valName != elemData[n]: continue
			n = self.getArgumentGroupIndex('%description')
			(description,typeName,inout) = ('', '', '')
			
			if n != -1 and elemData[n] != None:
				description = elemData[n]
			n = self.getArgumentGroupIndex('%type')
			if n != -1 and elemData[n] != None:
				typeName = elemData[n]
			n = self.getArgumentGroupIndex('%inout')
			if n != -1 and elemData[n] != None:
				inout = elemData[n]
			elif typeName != '':
				inout = self.getInOutType(typeName)
			return (inout, typeName, description)
		else:
			return '', '', ''
	
	def getOutputArgumentTemplate(self): return getvim('template_argument')
	def getFormatHeader(self): return getvim('format_header')
	def getFormatFooter(self): return getvim('format_footer')
	# �������Ϥ��뤫?
	def isAlignment(self):
		try:    return int(getvim('is_alignment')) != 0
		except: return False
	# �ؿ�������֤Υ���ǥ��ʸ��������
	def getArgumentGroupIndex(self, text):
		try:    return getvim('escapetext_argument').split(',').index(text)
		except: return -1

# K&R��������ε��Ҥ�?
# @return True: K&R�������� False:�����ǤϤʤ�
# @param text Ƚ���оݥƥ�����
def isK_and_RStyle(text):
	# �Ĥ���̤���{�ޤ�(���뤤������)�δ֤ˡ�;�������K&R���Ҥȸ��ʤ�
	# (���礦�Ƥ̤�)
	rb = text.find(')')
	if rb == -1: return False
	e = text.find('{', rb+1)
	return ';' in text[rb:e]

## 	startChar����endChar�ޤǤδ֤�ʸ����Υ��ԡ����֤���
##  include��True�ξ��ϡ�startChar,endChar��ޤ�롣
# @return 
# @param text      �����оݥƥ�����
# @param startChar ����ʸ����
# @param endChar   ��λʸ����
# @param include   startChar,endChar��ޤ�뤫?
def substrFindChar(text, startChar, endChar,include = False):
	assert(isinstance(startChar, str))
	assert(isinstance(endChar, str))
	(loff,roff) = (0,len(endChar)) if include else (len(startChar), 0)
	lb = text.find(startChar)
	if lb == -1:
		raise Exception()
	rb = text.find(endChar, lb+len(startChar))
	if rb == -1:
		raise Exception()
	return text[lb+loff:rb+roff], (lb,rb)

# ��������������ꥹ�Ȥ����
# @return �����ꥹ�Ȥȳ�̳��ϰ��֤Υڥ�
# @param text      �����оݥƥ�����
# @param startChar ����ʸ��
# @param endChar   ��λʸ��
# @param sepeartor ���ڤ�ʸ��
def splitArgumentPart(text, startChar='(', endChar=')',separator=','):
	assert(isinstance(separator, str))
	try:
		args = []
		part,(lb,rb) = substrFindChar(text, startChar, endChar)
		for item in (x.strip() for x in part.split(separator)):
			if len(item) > 0: args.append(item)
		return args, (lb,rb)
	except:
		return None,(-1,-1)

## text����separators�γ����Ǥ򸡺�����
## ���פ����Τ����ä��顢����ʹߤ������ޤ���
# @return �������ʸ����
# @param text       �����оݥƥ�����
# @param separators ���ʸ����
def stripCharsAfter(text, *separators):
	for separator in separators:
		eq = text.find(separator)
		if eq != -1: text = text[:eq]
	return text

def splitChars(text, *separators):
	for separator in separators:
		eq = text.find(separator)
		if eq != -1: return text[:eq], text[eq:]
	return text, ''

def rsplitChars(text, *separators):
	max_eq = -1
	for separator in separators:
		eq = text.rfind(separator)
		if eq == -1:
			continue
		if eq > max_eq:
			max_eq = eq
	if max_eq == -1:
		return text, ''
	else:
		return text[:max_eq+1].strip(), text[max_eq+1:].strip()

## C/C++�Ѥβ��Ͻ���
# @return TypeInfo���֥�������
# @param selectText ����ƥ�����
def parseFunctionCpp(selectText):
	obj = TypeInfo(selectText)
	obj.k_and_r = isK_and_RStyle(selectText)
	
	# ���Ԥ����
	selectText = replacem(selectText, ('\n', ' '), ('\t', ' '))
	args, (lb,rb) = splitArgumentPart(selectText)
	if args == None: return None
	sep1 = selectText.rfind(' ', 0, lb)
	if sep1 != -1:
		obj.returnValue  = selectText[0:sep1]
	
	obj.funcName = selectText[sep1+1:lb]
	# �ǥե�����ͻ���(=)����ζ���ȡ��������ζ���ν���
	m_eq = re.compile(r'\s*=\s*')
	m_ar = re.compile(r'\s*\[')
	for item in args:
		item = m_eq.sub('=', item)
		item = m_ar.sub('[', item)
		valType, valName = rsplitChars(item, ' ', '\t', '*', '&')
		if valName ==  '':
			# �ȡ����󤬰�Ĥ����ʤ���硢
			# �ե����륿���פ�C++�ξ��Ϸ�̾�Ǥ����Τȸ��ʤ���
			# C�ξ����ѿ�̾�Ǥ����ΤȤߤʤ�
			# (C�Ǥ��ѿ�̾��ά�����Ĥ��줺��C++�ǤϷ�̾��ά�����Ĥ���ʤ�����)
			if vim.eval('&ft') == 'c':
				valName = valType
				valType = ''
		valName = valName.lstrip(' \t*&')

		# ��int *��-> ��int*�פ�ľ��
		m_sp = re.compile(r'\s*(\*|&)')
		valType = m_sp.sub(r'\1', valType)
		
		# �ǥե�����͡�����ɽ���Ϻ��
		valName, valNamePrefix = splitChars(valName,'=','[')
		obj.arguments.append([valType, valName, valNamePrefix])
	def findargument(name):
		for argpair in obj.arguments:
			if name != argpair[1]: continue
			return argpair
		else: None
	# K&R����������ä������ü�ʽ���(�ȤäƤ��������ʤΤǱ���)
	if obj.k_and_r:
		# ')'��'{'�ޤǤ�ʸ�����ȴ���Ф�
		e = selectText.find('{', rb+1)
		ms = re.compile(r'\s*,\s*')
		mp = re.compile(r'\s*\*')
		# ��;�פ���ڤ�ʸ���Ȥ���ʬ��
		for arg in selectText[rb+1:e].split(';'):
			# pointer(*)��ľ���ˤ������ȡ���,������ζ�������
			arg = arg.strip()
			arg = ms.sub(',', arg)
			arg = mp.sub('*', arg)
			# ' 'or'\t'or'*'���ܤȤ��ơ���̾���ѿ�̾��ʬ��
			sep = arg.rfind(' ')
			if sep==-1: sep=arg.rfind('\t')
			if sep!=-1:
				valType = arg[:sep]
				names = arg[sep+1:]
			elif '*' in arg:
				sep = arg.rfind('*')
				valType = arg[:sep+1]
				names = arg[sep+1:]
			else:
				valType = 'int'
				names = arg
			# �������ǹ��ۤ��������ꥹ�Ȥȡ��ѿ�̾�ǥޥå��󥰤�Ȥ�
			# ���פ�������η�̾�����ꤹ�롣
			for valName in names.split(','):
				try: findargument(valName)[0] = valType
				except: pass
	# 
	obj.parseOK = True
	return obj

# PHP�Ѥβ��Ͻ���
# @return �����󥪥֥�������
# @param selectText ����ƥ�����
def parseFunctionPHP(selectText):
	obj = TypeInfo(selectText)
	# ���Ԥ����
	selectText = replacem(selectText,('\t', ' '), ('\n', ' '))
	args, (lb, rb) = splitArgumentPart(selectText)
	if args == None: return None
	sep1 = selectText.rfind('&', 0, lb)
	if sep1 == -1: sep1 = selectText.rfind(' ', 0, lb)
	obj.accessable = typePublic
	obj.returnValue = 'function' # dummy
	if sep1 != -1:
		for item in selectText[0:sep1].split():
			word = item.strip()
			if word == '' or word == '&' or word == 'function': continue
			if word == 'public': obj.accessable = typePublic
			elif word == 'protected': obj.accessable = typeProtected
			elif word  == 'private': obj.accessable = typePrivate
	
	obj.funcName = selectText[sep1+1:lb]
	types = lambda x: '&' if '&' in x else ''
	for x in args:
		valName, valNamePrefix = splitChars(x, '=')
		valName = valName.lstrip('&$') # �ѿ�̾��Ƭ��&$�Ͻ���
		obj.arguments.append([types(x), valName, valNamePrefix])
	obj.parseOK = True
	return obj

# Python�Ѥβ��Ͻ���
# @return �����󥪥֥�������
# @param selectText ����ƥ�����
def parseFunctionPython(selectText):
	obj = TypeInfo(selectText)
	# ���Ԥ����
	selectText = replacem(selectText,('\t', ' '), ('\n', ' '))
	args, (lb, rb) = splitArgumentPart(selectText)
	if args == None: return None
	sep1 = selectText.rfind('&', 0, lb)
	if sep1 == -1: sep1 = selectText.rfind(' ', 0, lb)
	obj.returnValue = 'function' # dummy
	obj.funcName = selectText[sep1+1:lb]
	obj.accessable = typePrivate if obj.funcName.startswith('__') else \
	                 typePublic
	for x in args:
		valName, valNamePrefix = splitChars(x, '=')
		valName = valName.lstrip('*')
		obj.arguments.append(['', valName, valNamePrefix])

	# ��Ƭ���Ǥ�self�ξ�硢����
	if len(obj.arguments) > 0 and obj.arguments[0][1] == 'self':
		obj.arguments.pop(0)
	obj.parseOK = True
	return obj

# JavaScript�Ѥβ��Ͻ���
# @return �����󥪥֥�������
# @param selectText ����ƥ�����
def parseFunctionJS(selectText):
	obj = TypeInfo(selectText)
	# ���Ԥ����
	selectText = replacem(selectText, ('\t', ' '),('\n', ' '))
	args, (lb, rb) = splitArgumentPart(selectText)
	if args == None: return None
	sep1 = selectText.rfind(' ', 0, lb)
	obj.returnValue = 'function' # dummy
	obj.funcName = selectText[sep1+1:lb]
	for x in args:
		valName, valNamePrefix = splitChars(x, '=')
		obj.arguments.append(['', valName, valNamePrefix])
	obj.parseOK = True
	return obj

# Perl�Ѥβ��Ͻ���
# @return �����󥪥֥�������
# @param selectText ����ƥ�����
def parseFunctionPerl(selectText):
	obj = TypeInfo(selectText)
	
	patName = re.compile(r'\s*sub\s+(\w+)')
	pat1 = re.compile(r'(?=.+@_).*\((.+?)\)')
	pat2 = re.compile(r'(?=.+=\s*shift)\s*(my)?\s*(.+?)\s*?=')
	
	args = ''
	for line in selectText.replace(';','\n').splitlines():
		mf = patName.match(line)
		if mf: obj.funcName = mf.group(1)
		m1 = pat1.match(line)
		if m1: args += m1.group(1)
		m2 = pat2.match(line)
		if m2: args += m2.group(2)
	
	for arg in args.replace('$',',').split(','):
		arg = arg.strip()
		if len(arg) == 0: continue
		obj.arguments.append(['', arg, ''])
	# ��Ƭ���Ǥ�self�ξ�硢����
	if len(obj.arguments) > 0 and obj.arguments[0][1] =='self':
		obj.arguments.pop(0)
	
	obj.parseOK = len(obj.funcName) > 0
	return obj

# ���˱����ƽ����򿶤�ʬ����
# @return �����󥪥֥�������
# @param selectText ����ƥ�����
def parseFunction(selectText):
	ft = vim.eval('&ft')
	if ft == 'c' or ft == 'cpp': return parseFunctionCpp(selectText)
	elif ft == 'php':            return parseFunctionPHP(selectText)
	elif ft == 'javascript':     return parseFunctionJS(selectText)
	elif ft == 'perl':           return parseFunctionPerl(selectText)
	elif ft == 'python':         return parseFunctionPython(selectText)
	elif ft == 'ruby':           return parseFunctionPHP(selectText) # ���٤�
	else:
		# �ʤ�����狼��ʤ����ϤȤꤢ����C/C++�Ȥ��ƽ���
		# (����Ǥ��������������⤷��󤱤ɡ���)
		return parseFunctionCpp(selectText)

# �����󥯥饹
class TypeInfo:
	originalText = ''
	parseOK = False
	funcName = ''
	returnValue = ''
	arguments = []
	k_and_r = False
	
	def __init__(self, text):
		self.originalText = text
	
	## 	��������������������������?
	# @return True:���� False:����
	def isParseOK(self):
		return self.parseOK
	
	## 	����ͤ˴ؤ������Ϥ��뤫?
	# @return True:���� False:�ʤ����ޤ��Ͻ��Ϥ��ʤ�
	def hasReturnValue(self):
		if hasattr(self, "returnValue") == False:
			return False
		# void�����ä�����Ϥ��ʤ�
		m = re.compile('.*void$')
		return len(self.returnValue) >= 1 and m.match(self.returnValue) == None
	# ����ǥ�Ȥ����
	# @return ����ǥ��ʸ����
	def getIndent(self):
		if hasattr(self, "originalText") == False: return ''
		if hasattr(self, "indentText") == True: return self.indentText
		
		self.indentText = ''
		for i in self.originalText:
			# if i == '\n': continue
			if i not in " \t": break
			self.indentText += i
		return self.indentText
	## 	�����ꥹ�Ȥμ���
	# @return �����ꥹ��
	def getArguments(self): return getattr(self, "arguments", [])
	## 	����;�������
	# @return ����;���
	def getReturnValue(self): return getattr(self, "returnValue", '')
	## 	�ؿ�̾�����
	# @return �ؿ�̾��ɽ��ʸ����
	def getFunctionName(self): return getattr(self, "funcName", '')
	## 	�����ꥹ�ȤΤ�������Ĺ�ΰ���̾��Ĺ�������
	# @return ʸ����Ĺ(int)
	def getLongestNameLen(self):
		try:
			return max([len(i[1]) for i in self.getArguments()])
		except:
			return 0
	## 	�����ꥹ�ȤΤ�������Ĺ�������ϥ�����([in],[out],[in,out])��Ĺ�������
	# @return �����ϥ����פΤ�������Ĺ��Ĺ��
	# @param styles ���Ϸ�������
	def getLongestTypeLen(self, styles):
		try:
			return max([ len(styles.getInOutType(i[0])) for i in self.getArguments()])
		except:
			return 0
	## 	�������Ϥ���ݤ�")"��������ʬ�Υƥ����Ȥ����
	# @note �������Ϥ�C/C++����
	# @return ")"��������ʬ�Υƥ�����
	def getTail(self):
		rb = self.originalText.find(')')
		return self.originalText[rb+1:]

# ��¸�Υ����Ȥ˴ؤ������
class CommentInfo:
	# �����Ȳ��Ͻ����ˤ�ä�����줿����
	lines = []
	# ��¸�Υ����Ȥ��񼰤˱�ä���ΤǤʤ��ä����Υ�����ʸ����
	briefs = []
	# dsfcg�ˤ�ä��������줿�����Ȥ�¸�ߤ��뤫?
	# @return �����Ȥ�̵ͭ
	###
	def hasGeneratedComments(self): return len(self.lines) > 0
	def append(self, item): self.lines.append(item)
	def appendBrief(self, line): self.briefs.append(line)

# �����Ȥ�brief���ҤΤߤǤ����ΤȤ��Ʋ���
# @return �����Ⱦ���
# @param selectText �����оݥƥ�����
# @param styles     �񼰾���
def parseBrief(selectText, styles):
	lines = selectText.splitlines(True)
	comments = CommentInfo()
	for line in lines:
		line,isComment = stripCommentChar(line)
		if isComment == False: continue
		if len(line) == 0: 
			comments.appendBrief('')
			continue
		if line[0] in ('!','/', '*'):
			line = line.lstrip(line[0])
		comments.appendBrief(line)
	return comments

## 	������ʸ������ʬ�Τߤ����
# @return ������ʸ���󤫤�ʤ�ԤΥꥹ��
# @param text �ƥ�����
def extractCommentPart(text):
	output = []
	commentTypes = getCommentWords()
	while True:
		for item in commentTypes:
			try:
				line,(lb,rb) = substrFindChar(text, item[0], item[1], True)
				output.append(line.rstrip('\n'))
				text = text.replace(text[lb:rb],'')
				break
			except: pass
		else:
			break
	return output

# ������������Ϥ��������Ⱦ��������
# Enter description here.
# @return �����Ⱦ���
# @param selectText vim¦�����򤵤줿�ƥ�����
# @param styles     ���Ϸ����˴ؤ����������
###
def parseComments(selectText, styles):
	def stripLine(lines, settingName):
		data = getvim(settingName).strip()
		if len(data) == 0: return lines
		i = 0
		for line in lines:
			if line.strip() == data: return lines[i+1:]
			i+=1
		else: return []
	
	# �إå����եå��ν񼰤��������Ƥ����顢���δ֤Υ����ȤΤߤ�
	# �����оݤȤ��롣�񼰤��������Ƥ��ʤ��ä��顢
	# ����ʸ���󤫤饳����������Ф��������оݤȤ���
	if getvim('format_header')+getvim('format_footer') != '':
		lines = selectText.splitlines()
		# �����ȥإå�����Ʊ��ν񼰤ιԤ����뤫�򸡺���������
		lines = stripLine(lines, 'format_header')
		# �����ȥեå�����Ʊ��ν񼰤����뤫�򸡺���������
		lines.reverse()
		lines = stripLine(lines, 'format_footer')
		lines.reverse()
	else:
		lines = extractCommentPart(selectText)
	
	# �ؿ���������������Ϥ�������򤿤�Ƥ���
	isBriefOnly = True
	comments = CommentInfo()
	for line in lines:
		# �����Ԥ�?
		if styles.isArgumentLine(line):
			comments.append((typeArg, styles.parseArgument(line)))
			isBriefOnly = False
		# ����͹Ԥ�?
		elif styles.isReturnLine(line):
			comments.append((typeReturn, styles.parseReturn(line)))
			isBriefOnly = False # ����¾�ε���
		else:
			comments.append((typeOther, line))
	# �⤷��¸�Υ����Ȥ��ʤ��ä��顢briaf���Ҥ����Υ����ȤȤ��Ƥ�
	# ���Ϥ��ߤ�
	if isBriefOnly: return parseBrief(selectText, styles)
	else:			return comments

def escapeChar(text):
	return replacem(text, 
		(r'\n', '\n'), (r'\r', '\r'),(r'\t', '\t'))
def escapeChars(comment):
	return [ escapeChar(x) for x in comment ]

def getCommentWords():
	commentTypes = []
	try:
		comments = getvim('comment_words')
		for comment in comments:
			if isinstance(comment, list) == False: continue
			if len(comment) < 2: continue
			commentTypes.append(escapeChars(comment))
	except: pass
	return commentTypes

# �����ȹԤ�?
def stripCommentChar(line):
	# ��ñ�̥����Ȥ���Ƭ�Υ���ǥ�Ȥ����
	commentTypes = getCommentWords()
	for item in commentTypes:
		s = line.find(item[0])
		if s == -1: continue
		line = line.lstrip(' \t')
		break
	
	while True:
		striped = False
		for item in commentTypes:
			try:
				line,(lb,rb) = substrFindChar(line, item[0], item[1])
				striped = True
			except: pass
		else:
			return line, striped

# �����Ƚ���
def stripComment(selectText):
	commentTypes = getCommentWords()
	lines = []
	for line in selectText.splitlines():
		for item in commentTypes:
			n = line.find(item[0])
			if n == -1: continue
			lines.append(line.lstrip('\t '))
			break
		else: lines.append(line)
	
	isAddCR = selectText[-1] == '\n'
	
	selectText = "\n".join(lines)
	# �⤷���������Ԥξ�硢splitlines�ǺǸ�β��Ԥϼ�����Τǡ��䴰����
	if isAddCR: selectText = selectText + '\n'
	
	while True:
		for item in commentTypes:
			n = selectText.find(item[0])
			if n == -1: continue
			
			endPos = selectText.find(item[1], n+len(item[0]))
			if endPos == -1: continue
			
			selectText = selectText.replace(selectText[n:endPos+len(item[1])], '')
			break
		else:
			# �ǽ�β��Ԥ�����
			selectText = selectText.lstrip('\n')
			return selectText

def getArgumentNames(commentInfo, styles):
	nameIndex = styles.getArgumentGroupIndex('%name')
	if nameIndex == -1: return [""]
	names = []
	for item in commentInfo:
		elemType, elemData = item[0], item[1]
		if elemType != typeArg: continue
		names.append(elemData[nameIndex])
	else: return [""]
	return names
def getInOutTypes(commentInfo, styles):
	inoutIndex = styles.getArgumentGroupIndex('%inout')
	if inoutIndex == -1: return [""]
	inouts = [""]
	for item in commentInfo:
		elemType, elemData = item[0], item[1]
		if elemType != typeArg: continue
		inouts.append(elemData[inoutIndex])
	else: return [""]
	return inouts

# �桼��������ɤ򥨥������פ���
def escapeUserKeywords(text, commentInfo):
	keywords = getvim('user_keywords')
	if isinstance(keywords, dict) == False: return text
	
	for keyword in keywords:
		if text.find('%'+keyword) == -1: continue
		data = keywords[keyword]
		if keyword == 'defaultmsg' and len(commentInfo.briefs)>0:
			i = 0
			line = text
			text = ''
			for brief in commentInfo.briefs:
				if i>0: text += '\n'
				text += line.replace('%'+keyword, brief)
				i += 1
		else:
			text = text.replace('%'+keyword, data)
	return text

def getPermissionText(typeInfo):
	texts = getvim('permission_tags')
	if hasattr(typeInfo,'accessable') == False:
		return texts[typePublic]
	a = typeInfo.accessable
	if a == typePublic: return texts[typePublic]
	elif a == typeProtected: return texts[typeProtected]
	else: return texts[typePrivate]

def makeReturnPart(typeInfo, styles, default = None):
	if typeInfo.hasReturnValue() == False: return default
	funcName = getattr(typeInfo, "funcName", '')
	work = styles.getOutputReturnTemplate()
	return replacem(work,
		('%description', ''), ('%function', funcName))
	
# ��������
def makeNewComment(typeInfo, styles, commentInfo):
	# �Ǥ�̾����Ĺ������̾�ˤ��碌�ƥ���ǥ�Ȥ��뤿��˺�Ĺ��̾����Ĵ�٤�
	longestNameLen = typeInfo.getLongestNameLen()
	longestTypeLen = typeInfo.getLongestTypeLen(styles)

	funcName = getattr(typeInfo, "funcName", '')
	#
	output = ''
	isOutA, isOutR = False, False
	descIndex = 1
	for item in styles.getElementOrder():
		if item == 'D':
			msg = styles.getDescriptionTemplate(descIndex)
			msg = escapeUserKeywords(msg, commentInfo)
			msg = msg.replace('%function', funcName)
			output += escapeChar(msg) + '\n'
			descIndex+=1
		elif item == 'A' and isOutA == False:
			isOutA = True
			arguments = typeInfo.getArguments()
			for item in arguments:
				outputArg = styles.getOutputArgumentTemplate()
				valType, valName = item[0], item[1]
				
				# void,�ޤ���...���оݳ�
				if valType == "void" or valType == "...": continue
				
				# ����ǥ�Ȥ򤢤碌��
				if longestNameLen > 0:
					valName = valName.ljust(longestNameLen)
				ioType = styles.getInOutType(valType)
				if longestTypeLen > 0:
					ioType = ioType.ljust(longestTypeLen)
				
				outputArg = replacem(outputArg,
					('%type', valType), ('%name', valName),
					('%inout', ioType), ('%description', ''),
					('%function', funcName))
				output += outputArg + '\n'
		elif item == 'R' and isOutR == False:
			isOutR = True
			work = makeReturnPart(typeInfo, styles)
			if work: output += work + '\n'
		elif item == 'P' and typeInfo and hasattr(typeInfo, 'accessable'):
			isOutP = True
			work = styles.getPermissionTemplate()
			work = replacem(work,
				('%permission', getPermissionText(typeInfo)), ('%function', funcName))
			output += work + '\n'
	return output

# �ޡ�������
# @return ���������Υƥ�����
# @param typeInfo    ������
# @param styles      �񼰾���
# @param commentInfo ��¸�Υ����Ⱦ���
def makeMergeComment(typeInfo, styles, commentInfo):
	lines = []
	argIndex = 0
	# ��¸�Υ����Ȥ��������������Τ�����
	# �ؿ�����������������Τߤ����
	isOutR = False
	comments = commentInfo.lines
	for item in comments:
		elemType, elemData = item[0], item[1]
		if elemType == typeOther:
			lines.append(elemData)
		elif elemType == typeArg:
			lines.append(argIndex)
			argIndex+=1
		elif elemType == typeReturn:
			# ����ͤ�void���ä��ꤷ���顢���Ϥ��ʤ�
			if typeInfo == None: continue
			if typeInfo.hasReturnValue() == False: continue
			work = styles.getOutputReturnTemplate()
			for i in range(0, len(elemData)):
				escapeText = styles.getReturnEscapeText(i)
				if escapeText == '': continue
				work = work.replace(escapeText, elemData[i])
			lines.append(work)
			isOutR = True
	# ����塢����ͤȰ����Τɤ��餬��˽��Ϥ���뤫?
	def isReturnBeforeArg():
		for item in styles.getElementOrder():
			if item == 'A': return False
			elif item == 'R': return True
		else: return True
	# ��¸������͹Ԥ�¸�ߤ��ʤ����ϡ�������������Ԥ���
	work  = makeReturnPart(typeInfo, styles)
	if isOutR == False and work:
		try:
			# �����������ͤ���˽��Ϥ�����ϰ����Ԥ�ľ���������Ǥʤ����ϰ����Ԥ�ľ��ˤ���
			insertPos = lines.index(0) if isReturnBeforeArg() else \
						lines.index(argIndex-1)+1
			lines.insert(insertPos, work)
		except: lines.append(work)
	
	# �Ǥ�̾����Ĺ������̾�ˤ��碌�ƥ���ǥ�Ȥ��뤿��˺�Ĺ��̾����Ĵ�٤�
	longestNameLen = max(
		[typeInfo.getLongestNameLen(),
		 max([ len(x) for x in getArgumentNames(comments, styles)])]
	)
	longestTypeLen = max(
		[typeInfo.getLongestTypeLen(styles),
		 max([ len(x) for x in getInOutTypes(comments, styles)])]
	)
	# �ؿ�����������������������������˽���
	lastindex = None
	arguments = typeInfo.getArguments()
	for i in range(0, len(arguments)):
		item = arguments[i]
		valType, valName = item[0], item[1]
		
		# void,�ޤ���...���оݳ�
		if valType in ("void", "..."): continue
		
		# ��¸�Υ����Ⱦ��󤫤顢̾�������פ����ѿ��˴ؤ����������
		(ioType, typeName, desc) = styles.getArgumentInfo(comments, valName)
		if ioType == '': ioType = styles.getInOutType(valType)
		if typeName != '': valType = typeName
		
		if longestNameLen > 0: valName = valName.ljust(longestNameLen)
		if longestTypeLen > 0: ioType = ioType.ljust(longestTypeLen)
		
		outputArg = styles.getOutputArgumentTemplate()
		outputArg = replacem(outputArg,
			('%type', valType), ('%name', valName),
			('%inout', ioType), ('%description', desc))
		try:
			n = lines.index(i)
			lines[n] = outputArg
			lastindex = n
		except:
			if lastindex == None:
				lines.append(outputArg)
			else:
				lines.insert(lastindex+1, outputArg)
				lastindex+=1
	
	# lines������Ǥ�integer���ΤޤޤˤʤäƤ����Τ����
	while True:
		for item in lines:
			if isinstance(item, int):
				lines.remove(item)
				break
		else: break
	
	return "\n".join(lines) + "\n"

##  �ؿ����ν���
# @return 
# @param typeInfo ������
# @param styles   ���Ϸ�������
def makeFunctionPart(typeInfo, styles):
	if isAlignment(typeInfo, styles) == False:
		return typeInfo.originalText.lstrip('\n')
	output = ''
	
	# ����ͤν���
	output += typeInfo.getReturnValue()
	output += ' '
	
	# �ؿ�̾�ν���
	funcName = typeInfo.getFunctionName()
	output += typeInfo.funcName + '('
	arguments = typeInfo.getArguments()
	if len(arguments) > 0:
		output += '\n'
	
	last = len(arguments) - 1
	# �����ν���
	for i, item in enumerate(arguments):
		argType, argName, argPrefix = item[0], item[1], item[2]
		output += '\t' + argType + ' ' + argName + argPrefix
		if i != last: output += ',\n'
		else:         output += '\n'
	output += ')'
	# �Ĥ����ʬ�򤯤äĤ���
	tails = typeInfo.getTail().splitlines(True)
	# �Ĥ���̤θ夬{���ä���硢�֤˲��Ԥ������
	if len(tails) > 0 and '{' in tails[0]:
		tails[0] = tails[0].replace('{', '\n{')
	
	output += "".join(tails)
	return output

## �������Ϥ��뤫�ɤ�����Ƚ�ꤷ�ޤ�
# @return True:���� False:���ʤ�
# @param typeInfo ������
# @param styles   �񼰾���
def isAlignment(typeInfo, styles):
	# �ѡ����˼��Ԥ����顢�������ϤϤ��ʤ������ꥸ�ʥ�Τ򤽤Τޤ޽���
	return typeInfo.isParseOK()  and styles.isAlignment()  and \
	   typeInfo.k_and_r == False

## text�γƹԤ��Ф��ƥ���ǥ�Ȥ����ꤷ�ޤ���
# @return ����ǥ��������Υƥ�����
# @param text     �����оݥƥ�����
# @param typeInfo �ؿ������Ϸ�̥ǡ���
def alignmentIndent(text, typeInfo):
	assert(typeInfo)
	output = ''
	for line in text.splitlines(True):
		output += typeInfo.getIndent() + line
	return output

##  ��������������
# @return �������줿���������Υƥ�����ʸ����
# @param typeInfo    ������
# @param styles      ���Ϸ�������
# @param commentInfo �����Ⱦ���
def makeCommentPart(typeInfo, styles, commentInfo):
	commentPart = ''
	header = styles.getFormatHeader()
	if len(header) > 0: commentPart += header + '\n'
	if commentInfo.hasGeneratedComments() == False:
		commentPart += makeNewComment(typeInfo, styles, commentInfo)
	else:
		commentPart += makeMergeComment(typeInfo, styles, commentInfo)
	footer = styles.getFormatFooter()
	if len(footer) > 0: commentPart += footer + '\n'
	return commentPart

## ������ȥ����Ⱦ���򸵤˴ؿ�������Ҥ�����
# @param typeInfo    �ؿ������Ϸ�̥ǡ���
# @param styles      �����������
# @param commentInfo �����Ⱦ���
def makeFuncDescription(typeInfo, styles, commentInfo):
	if typeInfo == None: return None
	if commentInfo == None: return None
	
	commentPart = makeCommentPart(typeInfo, styles, commentInfo)
	funcPart = makeFunctionPart(typeInfo, styles)
	
	# �������Ϥ��ʤ���硢�ؿ����ϸ��Τޤ޽��Ϥ���Τ�
	# �����������Ф��ƤΤߥ���ǥ�Ȥ�Ԥ��ޤ���
	if isAlignment(typeInfo, styles):
		return alignmentIndent(commentPart+funcPart, typeInfo)
	else:
		return alignmentIndent(commentPart, typeInfo) + funcPart

###################################
###################################
setvim(('result_ok', 0), ('result', ''))

styles = StyleInfo()

# vim¦�����򤵤줿�ƥ����Ȥ����
text = getvim('select')

# ������������Ϥ�����¸�Υ����Ⱦ������������
commentInfo = parseComments(text, styles)
# �ؿ����������Ϥ������������������
typeInfo = parseFunction(stripComment(text))

# �����Ⱦ���ȷ�����򸵤ˡ��ؿ������Ȥ�ޤ᤿�ؿ�������Ҥ�����
output = makeFuncDescription(typeInfo, styles, commentInfo)

# ��̤�vim¦���֤�
if output != None:
	setvim(('result_ok', 1),('result', output))
################################################################################

END_OF_PYTHON
	unlet g:dsfcg_select
" Python������¦���������줿��̤������ꡢ�֤�
	let result = g:dsfcg_result
	let ok = g:dsfcg_result_ok
	unlet g:dsfcg_result
	unlet g:dsfcg_result_ok
	return [result, ok]
endfunction

" �ؿ������Ȥ�����
function! DSMakeFunctionComment()
	" ���Ū�˻��Ѥ���a�쥸����������
	let a_value = getreg('a', 1)
	let a_mode  = getregtype('a')
	" �����Ȥ���������Ž���դ�
	let [@a,ok] = s:makeComment()
	if ok != 0
		execute "normal! gv\"_d0\"aP"
	endif
	" a�쥸����������
	call setreg('a', a_value, a_mode)
endfunction

" get select text.
" http://vim.g.hatena.ne.jp/keyword/%e9%81%b8%e6%8a%9e%e3%81%95%e3%82%8c%e3%81%9f%e3%83%86%e3%82%ad%e3%82%b9%e3%83%88%e3%81%ae%e5%8f%96%e5%be%97
function! s:selected_text(...)
  let [visual_p, pos] = [mode() =~# "[vV\<C-v>]", getpos('.')]
  let [r_, r_t] = [@@, getregtype('"')]
  let [r0, r0t] = [@0, getregtype('0')]
  if &cb == "unnamed"
	  let [rast, rastt] = [@*, getregtype('*')]
  endif


  if visual_p
    execute "normal! \<Esc>"
  endif
  silent normal! gvy
  let [_, _t] = [@@, getregtype('"')]

  call setreg('"', r_, r_t)
  call setreg('0', r0, r0t)
  " set cb=unnamed�ʴĶ����ȡ�yank,paste��"*�쥸�������Ȥ���ΤǤ���������Ǥ���褦��
  " (¾������Υ쥸������Ȥ��褦�����ꤵ��Ƥ������ˤĤ��Ƥ�����)
  if &cb == "unnamed"
	  call setreg('*', rast, rastt)
  endif
  if visual_p
    normal! gv
  else
    call setpos('.', pos)
  endif
  return a:0 && a:1 ? [_, _t] : _
endfunction

if !exists('g:dsfcg_enable_mapping') || g:dsfcg_enable_mapping != 0
	vnoremap m :<c-u>call DSMakeFunctionComment()<cr>
endif

