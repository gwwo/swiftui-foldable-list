//
//  Model.swift
//  Foldable List
//
//  Created by gwwo on 27/7/2022.
//


struct ListInfo {
    var remain: Int
    var passed: Int
    var head: EntryContent
    var tail: EntryContent
    var body: [EntryContent]
}


class ListModel: FoldableModel {

    private var current: Int = 0
    private var passed: Int = 0
    private var remain: Int = 0
    private var words: [Word] = []
    
    var info: ListInfo {
        let head: Entry = passed != 0 ? .backward : .vocab
        let tail: Entry = passed != current ? .resume
                        : remain != 0 ? .forward
                        : .restart
        return ListInfo(
            remain: remain, passed: passed,
            head: EntryContent(leading: -passed, entry: head),
            tail: EntryContent(leading: words.count + remain + 1, entry: tail),
            body: words.enumerated().map { i, word in EntryContent(leading: i + 1, entry: .word(word))}
        )
    }

    private func forward(seek: Int) async {
        async let folding: () = fold()
        async let fetching = fetchWords(from: seek, num: 10)
        await folding
        (words, remain) = await fetching
        passed = seek
        current = seek
        await unfold()
    }
    
    private func backward() async {
        async let folding: () = fold()
        async let fetching = fetchWords(from: passed - 10, num: 10)
        await folding
        
        (words, remain) = await fetching
        passed = passed - words.count
        await unfold()
    }
    
    func tap(entry: Entry) {
        Task {
            switch entry {
            case .forward:
                await forward(seek: passed + words.count)
            case .backward:
                await backward()
            case .restart:
                await forward(seek: 0)
            case .resume:
                await forward(seek: current)
            case _:
                return
            }
        }
    }
}



struct Word: Equatable {
    var spelling: String
    var prompt: String
}

enum Entry: Equatable {
    case word(Word)
    case forward, backward, restart, vocab, resume
    var show: (String, String) {
        switch self {
        case .word(let word):
            return (word.spelling, word.prompt)
        case .forward:
            return ("proceed", "v. 前进")
        case .backward:
            return ("review", "v. 回顾")
        case .restart:
            return ("restart", "v. 重新开始")
        case .vocab:
            return ("vocabulary", "n. 词汇表")
        case .resume:
            return ("resume", "v. 继续")
        }
    }
}

struct EntryContent {
    var leading: Int
    var entry: Entry
    var left: String { entry.show.0 }
    var right: String { entry.show.1 }
}
