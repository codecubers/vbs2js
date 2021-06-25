"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const os_1 = require("os");
function extract_functions(code, pub=false) {
    let rx = '[ \t]*FUNCTION[ \t]*(?:.*[\r\n])*?(.*)END FUNCTION[ \t]*'
    if (pub) rx = '[ \t]*PUBLIC' + rx;
    var re = new RegExp(rx, 'igm');
    return code.match(re)
}
function extract_subs(code, pub=false) {
    let rx = '[ \t]*SUB[ \t]*(?:.*[\r\n])*?(.*)END SUB[ \t]*'
    if (pub) rx = '[ \t]*PUBLIC' + rx;
    var re = new RegExp(rx, 'igm');
    return code.match(re)
}
function extract_props(code, pub=false) {
    let rx = '[ \t]*PROPERTY[ \t]*(?:.*[\r\n])*?(.*)END PROPERTY[ \t]*'
    if (pub) rx = '[ \t]*PUBLIC' + rx;
    var re = new RegExp(rx, 'igm');
    return code.match(re)
}

function extract_classes(code) {
    var re = new RegExp('[ \t]*CLASS[ \t]*(?:.*[\r\n])*?(.*)END CLASS[ \t]*', 'igm');
    return code.match(re)
}

function removeCommentsStart(code) {
    //^[ \t]*['].*
    //[.]*['].*$
    return code.replace(/[.]*['](.*)[^"]$/gm, '').replace(/[\r\n][\r\n][\r\n]+/gm, '\n')
}

function classExtends(code) {
    // var re = new RegExp('CLASS[\s]+(\w+)[\s]+(?:extends[\s]+(\w+))(.*)END Class', 'igsm')
    var re = /CLASS[\s]+(\w+)[\s]+(?:extends[\s]+(\w+))(.*)END Class/igsm
    var match = re.exec(code);
    // console.log('match', match)
    return match ? {base: match[1], _extends: match[2]} : null

}
function extract_className(code) {
    // console.log('searching class name in:' + code)
    var re = /CLASS[ \t]+(\w+)(.*)END Class/igsm
    var match = re.exec(code);
    return match[1]
}

const fso = require('fs');
let sample = fso.readFileSync('C:\\Users\\nanda\\git\\xps.local.npm\\vbs-excel-utilities\\build\\export-bundle.vbs').toString();
// console.log(sample)
let temp = sample;
let classes = extract_classes(sample)
// console.log(extract_className(sample))
let i = 0
let newClasses = []
// let classFiles = {}
classes.forEach(cls => {
    let clsName = extract_className(cls);
    // console.log(`class ${clsName}:`)
    // cls = removeCommentsStart(cls)
    let _class = {
        name: clsName
    }
    let ext = classExtends(cls);
    if (ext) {
        let {base, _extends} = ext;
        _class.extends = _extends
        // console.log(`class ${base} extends ${_extends}`)
    }
    _class.body = cls
    // fso.writeFileSync('class-' + clsName + ".vbs",  cls)
    // classFiles[clsName] = cls;
    // console.log(cls)

    
    // console.log('\r\npublic methods:')
    let _clsTemp = cls;
    let _pubProps = extract_props(cls, true);
    if (_pubProps) {
        _class.pubProps = _pubProps;
        _pubProps.forEach((prop, index) => {
            _clsTemp = _clsTemp.replace(prop, 'PUB_PROP_' + index)
        })
    }
    let _pubSubs = extract_subs(cls, true);
    if (_pubSubs) {
        _class.pubSubs = _pubSubs;
        _pubSubs.forEach((sub, index) => {
            _clsTemp = _clsTemp.replace(sub, 'PUB_SUB_' + index)
        })
    }
    let _pubFuns = extract_functions(cls, true);
    if (_pubFuns) {
        _class.pubFuncs = _pubFuns;
        _pubFuns.forEach((fun, index) => {
            _clsTemp = _clsTemp.replace(fun, 'PUB_FUN_' + index)
        })
    }
    //TODO: Extract class initialize and terminates
    //TODO: extract private sub/function/properties
    

    _class.remaining = _clsTemp
    newClasses.push(_class)

    temp = temp.replace(cls, ``)
});

// console.log(Object.keys(classFiles))

// console.log(`remaining: ${temp}`)
fso.writeFileSync('./remaining.vbs', temp)
// console.log(extract_subs(temp))
// console.log(extract_functions(temp));

fso.writeFileSync('./classes-overall.json', JSON.stringify(newClasses, null, 2));