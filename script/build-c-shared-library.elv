#elvish script
fn scriptWD {
    wd=(path-dir (src)[path])
    echo cd $wd
    cd $wd
}

scriptWD
cd ../go

if (not ?(test -d ../assets/lib)) {
    mkdir -p ../assets/lib
}

ext=[&windows=dll &linux=so &darwin=dylib]

for libname [greeting] {
    for cond [
        [windows amd64] 
        [windows 386] 
        [linux amd64]
        [linux aarch64]
        [linux arm]
        [darwin amd64]
    ] {
        filename=../assets/lib/{$libname}-$cond[1].$ext[$cond[0]]
        echo GOOS=$cond[0] GOARCH=$cond[1] go build -buildmode=c-shared -o $filename ./$libname
        E:GOOS=$cond[0] E:GOARCH=$cond[1] go build -buildmode=c-shared -o $filename ./$libname
    }
}