#!/usr/bin/env python3

import os
import sys
import shutil

baseScript = '''
    jsContext[@"FUNCTION_NAME"] = BLOCK_DECLARATION {
        BOOL isFuncPtr = [symbol hasPrefix:@"*"];
        void *handle = dlsym(dlopen(0, RTLD_NOW), isFuncPtr ? [symbol substringFromIndex:1].UTF8String : symbol.UTF8String);
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
    'simd_float2': {
        "formalName": "Vector2",
        "jsTypeString": "JSValue *",
        "jsTypeConversion": lambda s: f'[JSValueSoft valueWithObject:@{{ @"x":@({s}.x), @"y":@({s}.y) }} inContext:_gAppJSContext]',
        "jsTypeDefault": "nil",
        "jsTypeCondition": lambda s: f'{s}.isObject',
        "jsTypeToNativeConversion": lambda s: f'simd_make_float2({s}[@"x"].toDouble, {s}[@"y"].toDouble)'
    },
    'simd_float3': {
        "formalName": "Vector3",
        "jsTypeString": "JSValue *",
        "jsTypeConversion": lambda s: f'[JSValueSoft valueWithObject:@{{ @"x":@({s}.x), @"y":@({s}.y), @"z":@({s}.z) }} inContext:_gAppJSContext]',
        "jsTypeDefault": "nil",
        "jsTypeCondition": lambda s: f'{s}.isObject',
        "jsTypeToNativeConversion": lambda s: f'simd_make_float3({s}[@"x"].toDouble, {s}[@"y"].toDouble, {s}[@"z"].toDouble)'
    },
    'simd_float4': {
        "formalName": "Vector4",
        "jsTypeString": "JSValue *",
        "jsTypeConversion": lambda s: f'[JSValueSoft valueWithObject:@{{ @"x":@({s}.x), @"y":@({s}.y), @"z":@({s}.z), @"w":@({s}.w) }} inContext:_gAppJSContext]',
        "jsTypeDefault": "nil",
        "jsTypeCondition": lambda s: f'{s}.isObject',
        "jsTypeToNativeConversion": lambda s: f'simd_make_float4({s}[@"x"].toDouble, {s}[@"y"].toDouble, {s}[@"z"].toDouble, {s}[@"w"].toDouble)'
    },
    'CGRect': {
        "formalName": "Rect",
        "jsTypeString": "JSValue *",
        "jsTypeConversion": lambda s: f'[JSValueSoft valueWithRect:{s} inContext:_gAppJSContext]',
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
        "jsTypeCondition": lambda s: f'{s}.isObject',
        "jsTypeToNativeConversion": lambda s: s
    },
  }

def typeMap(type):
  return typeInfo.get(type)

def process_string(returnType, parameters):
    functionName = 'InvokeFunc_' + typeMap(returnType)['formalName']
    params = [f"{(typeMap(element)['formalName'])}{index}" for index, element in enumerate(parameters) ]
    functionName = "_".join([functionName] + params)


    block_decls = ", ".join(["NSString *symbol"] + [f"JSValue *arg{index}" for index, _ in enumerate(parameters)])
    blockDeclaration = f"^{typeMap(returnType)['jsTypeString']}({block_decls})"


    type_clause = [f"{(typeMap(element)['jsTypeCondition'](f'arg{index}'))}" for index, element in enumerate(parameters)]
    type_clause = " && ".join(type_clause) if len(type_clause) > 0 else "YES" 


    native_function_decl = f'{returnType} (*func)({", ".join(parameters)}) = isFuncPtr ? *((void **)handle) : handle;'


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



for returnType in typeInfo.keys():
  print(process_string(returnType, []))

for returnType in typeInfo.keys():
  for param0 in filter(lambda x: x != "void", typeInfo.keys()):
    print(process_string(returnType, [param0]))

for returnType in typeInfo.keys():
  for param0 in filter(lambda x: x != "void", typeInfo.keys()):
    for param1 in filter(lambda x: x != "void", typeInfo.keys()):
      if not (param0.startswith("simd") and param1.startswith("simd") and param0 != param1):
        print(process_string(returnType, [param0, param1]))


for param2 in filter(lambda x: x != "void", typeInfo.keys()):
  print(process_string("void", ["int", "const char *", param2]))
# for returnType in typeInfo.keys():
#   for param0 in filter(lambda x: x != "void", typeInfo.keys()):
#     for param1 in filter(lambda x: x != "void", typeInfo.keys()):
#       for param2 in filter(lambda x: x != "void", typeInfo.keys()):
#         print(process_string(returnType, [param0, param1, param2]))
