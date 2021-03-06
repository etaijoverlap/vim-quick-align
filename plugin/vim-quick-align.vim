" Vim plugin for easy alignment of source code.
" Maintainer: Franz Schanovsky <franz.schanovsky@gmail.com>
" Last Change: 01-06-2016
" This software is licensed under the EUPL V 1.1
"
" This software is provided "as is" without warranty of any kind, see the 
" respective section in the EUPL. USE AT YOUR OWN RISK.

if exists("g:QuickAlignLoaded")
    finish
endif

let g:QuickAlignLoaded = 1

function QuickAlignAdd()
    if !exists("b:QuickAlignPositions")
        let b:QuickAlignPositions = []
    endif
    let l:curpos = getpos(".")
    let l:row = l:curpos[1]
    let l:col = l:curpos[2]
    for l:pos in b:QuickAlignPositions
        if l:pos[0] == l:row 
            for l:c in l:pos[1]
                if l:c == l:col
                    echom printf("Position (%d, %d) is already in alignment list.", l:row, l:col)
                    return
                endif
            endfor
            call add(pos[1], l:col)
            echom printf("Added column %d to alignment entry for row %d (new depth: %d)", l:col, l:row, len(pos[1]))
            return
        endif
    endfor

    call add(b:QuickAlignPositions, [l:row, [l:col]])
    echom printf("Added position (%d,%d) to alignment list.", l:row, l:col)
endfunction

""function QuickAlignRemove()
""    if !exists("b:QuickAlignPositions")
""        return
""    endif
""    let l:curpos = getpos(".")
""    let l:row = l:curpos[1]
""    let l:col = l:curpos[2]
""    for l:il:pos in b:QuickAlignPositions
""        if l:pos[0] == l:row 
""            for l:c in l:pos[1]
""                if l:c == l:col
""                    echom printf("Position (%d, %d) is already in alignment list.", l:row, l:col)
""                    return
""                endif
""            endfor
""            call add(pos[1], l:col)
""            echom printf("Added column %d to alignment entry for row %d (new depth: %d)", l:col, l:row, len(pos[1]))
""            return
""        endif
""    endfor
""
""    call add(b:QuickAlignPositions, [l:row, [l:col]])
""    echom printf("Added position (%d,%d) to alignment list.", l:row, l:col)
""endfunction

function QuickAlignCompare(i1, i2)
    return a:i1 - a:i2
endfunction

function QuickAlignExec()
    if exists("b:QuickAlignPositions")
        let l:maxcols = 0
        for l:rowentry in b:QuickAlignPositions
            if len(l:rowentry[1]) > l:maxcols
                let l:maxcols = len(l:rowentry[1])
            endif
        endfor

        let l:colwidths = []
        for l:i in range(l:maxcols)
            call add(l:colwidths,0)
        endfor
        for l:rowentry in b:QuickAlignPositions
            let l:colentries = sort(l:rowentry[1], "QuickAlignCompare")
            for l:i in range(len(l:colwidths))
                if l:i >= len(l:colentries)
                    break
                endif
                if l:i == 0
                    let l:lower = 0
                else
                    let l:lower = l:colentries[l:i - 1]
                endif
                let l:colwidth = l:colentries[l:i] - l:lower
                if l:colwidth > l:colwidths[l:i]
                    let l:colwidths[l:i] = l:colwidth
                endif
            endfor
        endfor

        for l:rowentry in b:QuickAlignPositions
            let l:row = l:rowentry[0]
            let l:colentries = sort(l:rowentry[1], "QuickAlignCompare")
            let l:cumrowcorr = 0
            for l:i in range(l:maxcols)
                if l:i >= len(l:colentries)
                    break
                endif
                if l:i == 0
                    let l:lower = 0
                else
                    let l:lower = l:colentries[l:i - 1]
                endif
                let l:col = l:colentries[l:i]
                let l:colwidth = l:col - l:lower

                if l:colwidth < l:colwidths[l:i]
                    let l:colcorr = l:colwidths[l:i] - l:colwidth
                    call setpos(".",[0, l:row, l:col + l:cumrowcorr, 0])
                    for l:i in range(l:colcorr)
                        execute("normal!i ")
                    endfor
                    let l:cumrowcorr += l:colcorr
                endif
            endfor
        endfor

        let b:QuickAlignPositions = []
    endif
endfunction

function QuickAlignClean()
    let b:QuickAlignPositions = []
    echo "Alignment buffer was emptied."
endfunction

nnoremap <C-L><C-L> :call QuickAlignAdd()<CR>
nnoremap <C-L>e :call QuickAlignExec()<CR>
nnoremap <C-L>c :call QuickAlignClean()<CR>
