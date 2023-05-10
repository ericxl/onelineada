#!/usr/bin/env python3

import os
import sys
import shutil

baseScript = '''
    [self jsContext][@"FUNCTION_NAME"] = BLOCK_DECLARATION {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(RTLD_DEFAULT, isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
        if ( handle == NULL || (isFuncPtr && *((void **)handle) == NULL) ) 
        { } else {
            if ( TYPE_CONDITION_CLAUSE ) {
                NATIVE_FUNC_DECLARE
                NATIVE_FUNC_INVOKE
                JS_VALUE_RETURN
            } else { }
        }
        FALLBACK
    };'''

typeInfo = {
    'void': {
        "formalName": "Void",
        "jsTypeString": "void",
        "jsTypeConversion": lambda s: s
    },
    'BOOL': {
        "formalName": "Bool",
        "jsTypeString": "BOOL",
        "jsTypeConversion": lambda s: s,
        "jsTypeDefault": "NO",
        "jsTypeCondition": lambda s: f'{s}.isBoolean',
        "jsTypeToNativeConversion": lambda s: f'{s}.toBool'
    },
    'int': {
        "formalName": "Int",
        "jsTypeString": "int",
        "jsTypeConversion": lambda s: s,
        "jsTypeDefault": "0",
        "jsTypeCondition": lambda s: f'{s}.isNumber',
        "jsTypeToNativeConversion": lambda s: f'{s}.toNumber.intValue'
    },
    'float': {
        "formalName": "Float",
        "jsTypeString": "float",
        "jsTypeConversion": lambda s: s,
        "jsTypeDefault": "0",
        "jsTypeCondition": lambda s: f'{s}.isNumber',
        "jsTypeToNativeConversion": lambda s: f'{s}.toNumber.floatValue'
    },
    'double': {
        "formalName": "Double",
        "jsTypeString": "double",
        "jsTypeConversion": lambda s: s,
        "jsTypeDefault": "0",
        "jsTypeCondition": lambda s: f'{s}.isNumber',
        "jsTypeToNativeConversion": lambda s: f'{s}.toDouble'
    },
    'CGRect': {
        "formalName": "Rect",
        "jsTypeString": "JSValue *",
        "jsTypeConversion": lambda s: f'[JSValueSoft valueWithRect:{s} inContext:[self jsContext]]',
        "jsTypeDefault": "nil",
        "jsTypeCondition": lambda s: f'{s}.isObject',
        "jsTypeToNativeConversion": lambda s: f'{s}.toRect'
    },
    'const char *': {
        "formalName": "CharPtr",
        "jsTypeString": "NSString *",
        "jsTypeConversion": lambda s: f'[NSString stringWithUTF8String:{s}]',
        "jsTypeDefault": "nil",
        "jsTypeCondition": lambda s: f'{s}.isString',
        "jsTypeToNativeConversion": lambda s: f'{s}.toString.UTF8String'
    },
    'id': {
        "formalName": "Id",
        "jsTypeString": "JSValue *",
        "jsTypeConversion": lambda s: s,
        "jsTypeDefault": "nil",
        "jsTypeCondition": lambda s: f'({s}.isString || {s}.isArray || {s}.isDate || {s}.isObject || {s}.isNull || {s}.isUndefined)',
        "jsTypeToNativeConversion": lambda s: f'''({{ 
          id __value = nil; 
          if ( {s}.isString ) {{ __value = {s}.toString; }} 
          else if ( {s}.isArray ) {{ __value = {s}.toArray; }} 
          else if ( {s}.isDate ) {{ __value = {s}.toDate; }} 
          else if ( {s}.isObject || {s}.isNull || {s}.isUndefined ) {{ __value = {s}.toObject; }}
          __value; }})'''
    },
    'SEL': {
        "formalName": "Selector",
        "jsTypeString": "NSString *",
        "jsTypeConversion": lambda s: f'NSStringFromSelector({s})',
        "jsTypeDefault": "NULL",
        "jsTypeCondition": lambda s: f'{s}.isString',
        "jsTypeToNativeConversion": lambda s: f'NSSelectorFromString({s}.toString)'
    },
  }

def typeMap(type):
  return typeInfo.get(type)

def process_string(returnType, parameters):
    if parameters is None:
        functionName = 'LookupSymbol_' + typeMap(returnType)['formalName']
    else:
        functionName = 'InvokeFunc_' + typeMap(returnType)['formalName']
        params = [f"{(typeMap(element)['formalName'])}{index}" for index, element in enumerate(parameters) ]
        functionName = "_".join([functionName] + params)

    if parameters is None:
        jsvalue_decls = []
    else:
        jsvalue_decls = [f"JSValue *arg{index}" for index, _ in enumerate(parameters)]
    block_decls = ", ".join(["NSString *symbol"] + jsvalue_decls)
    blockDeclaration = f"^{typeMap(returnType)['jsTypeString']}({block_decls})"


    if parameters is None:
        type_clause = "YES"
    else:
        type_clause = [f"{(typeMap(element)['jsTypeCondition'](f'arg{index}'))}" for index, element in enumerate(parameters)]
        type_clause = " && ".join(type_clause) if len(type_clause) > 0 else "YES" 


    if parameters is None:
        if returnType == "id":
            native_function_decl = 'id __unsafe_unretained *func = isFuncPtr ? (id __unsafe_unretained *)(*((void **)handle)) : (id __unsafe_unretained *)handle;'
        else:
            native_function_decl = f'{returnType} (*func) = isFuncPtr ? *((void **)handle) : handle;'
    else:
        native_function_decl = f'{returnType} (*func)({", ".join(parameters)}) = isFuncPtr ? *((void **)handle) : handle;'


    if parameters is None:
        native_function_invoke = f'*func'
    else:
        func_value_params = [f"{(typeMap(element)['jsTypeToNativeConversion'](f'arg{index}'))}" for index, element in enumerate(parameters) ]
        native_function_invoke = f'func({", ".join(func_value_params)})'
    if returnType != "void":
        native_function_invoke = f'{returnType} result = {native_function_invoke};'
    else:
        native_function_invoke = f'{native_function_invoke};'

    if returnType != "void":
        jsvalue_return = f'return {typeMap(returnType)["jsTypeConversion"]("result")};'
    else:
        jsvalue_return = "return;"

    if returnType != "void":
        fallback = f'return {typeMap(returnType)["jsTypeDefault"]};'
    else:
       fallback = "return;"

    codeScript = baseScript
    codeScript = codeScript.replace("FUNCTION_NAME", functionName)
    codeScript = codeScript.replace("BLOCK_DECLARATION", blockDeclaration)
    codeScript = codeScript.replace("TYPE_CONDITION_CLAUSE", type_clause)
    codeScript = codeScript.replace("NATIVE_FUNC_DECLARE", native_function_decl)
    codeScript = codeScript.replace("NATIVE_FUNC_INVOKE", native_function_invoke)
    codeScript = codeScript.replace("JS_VALUE_RETURN", jsvalue_return)
    codeScript = codeScript.replace("FALLBACK", fallback)

    return codeScript


for returnType in filter(lambda x: x != "void", typeInfo.keys()):
  print(process_string(returnType, None))

for returnType in typeInfo.keys():
  print(process_string(returnType, []))

for returnType in typeInfo.keys():
  for param0 in filter(lambda x: x != "void", typeInfo.keys()):
    print(process_string(returnType, [param0]))

for returnType in typeInfo.keys():
  for param0 in filter(lambda x: x != "void", typeInfo.keys()):
    for param1 in filter(lambda x: x != "void", typeInfo.keys()):
      # if not (param0.startswith("NativeVector") and param1.startswith("NativeVector") and param0 != param1):
      print(process_string(returnType, [param0, param1]))

for returnType in typeInfo.keys():
  for param0 in filter(lambda x: x != "void", typeInfo.keys()):
    for param1 in filter(lambda x: x != "void", typeInfo.keys()):
      for param2 in filter(lambda x: x != "void", typeInfo.keys()):
        if returnType == "void" and param0 == "int" and param1 == "const char *":
          print(process_string(returnType, [param0, param1, param2]))
        if param0 == "id" and param1 == "SEL":
          print(process_string(returnType, [param0, param1, param2]))

# for returnType in typeInfo.keys():
#   for param0 in filter(lambda x: x != "void", typeInfo.keys()):
#     for param1 in filter(lambda x: x != "void", typeInfo.keys()):
#       for param2 in filter(lambda x: x != "void", typeInfo.keys()):
#         print(process_string(returnType, [param0, param1, param2]))
