//
//  MockServer.swift
//  Foldable List
//
//  Created by gwwo on 27/7/2022.
//



var database: [Word]{
    [
        ("divulge", "v. 泄露"),
        ("inadvertent", "adj. 粗心的，不留意的"),
        ("incontrovertible", "adj. 不容置疑的"),
        ("discursive", "adj. 杂乱无章的"),
        ("overbearing", "adj. 专横的，压倒性的"),
        ("rehash", "v. （没有实质改变地）重提"),
        ("perfunctory", "adj. 敷衍的，草率的"),
        ("compound", "v. 使…变糟糕"),
        ("specious", "adj. 似是而非的，假的"),
        ("vociferous", "adj. 吵吵嚷嚷的"),
        ("archaic", "adj. 过时的"),
        ("cordial", "adj. 热情友好的"),
        ("evanescent", "adj. 短暂的"),
        ("scorn", "v. 鄙视，嘲笑"),
        ("retrofit", "v. 翻新"),
        ("copious", "adj. 大量的"),
        ("haughty", "adj. 高傲的，傲慢的"),
        ("inveigle", "v. 诱骗"),
        ("requisite", "adj. 必要的"),
        ("touchstone", "n. 检验标准"),
        ("captious", "adj. 挑刺的，吹毛求疵的"),
        ("tribulation", "n. 痛苦（的经历）"),
        ("hermetic", "adj. 密闭的"),
//        ("braggadocio", "n. 自夸，吹牛大王"),
//        ("innocuous", "adj. 无害的"),
//        ("paragon", "n. 典范，模范"),
//        ("sectarian", "adj. 教派的，派系的"),
//        ("moribund", "adj. 濒临死亡的"),
//        ("corrode", "v. 腐蚀"),
//        ("endow", "v. 赋予"),
//        ("brusque", "adj. 唐突的，无礼的"),
//        ("nugatory", "adj. 不重要的"),
//        ("piecemeal", "adv. 一次少量地，一件一件地"),
//        ("labyrinthine", "adj. 复杂的"),
//        ("boorish", "adj. 粗鲁的，粗野的"),

    ].map { record in
        Word(spelling: record.0, prompt: record.1)
    }
}


func fetchWords(from index: Int, num: Int) async -> ([Word], Int) {
    return await withCheckedContinuation { con in
        let start = min(database.count, max(index, 0))
        let end = min(database.count, max(index + num, 0))
        let fetched = Array(database[start..<end])
        let remain = database.count - end
        con.resume(returning: (fetched, remain))
    }
}
