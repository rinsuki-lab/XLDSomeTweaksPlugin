//
//  MusicBrainzAPI.swift
//  XLDSomeTweaksPlugin
//
//  Created by user on 2025/11/04.
//

struct MusicBrainzDisc: Codable {
    let id: String
}

struct MusicBrainzMedia: Codable {
    let position: Int
    let title: String
    let format: String
    let discs: [MusicBrainzDisc]
}

struct MusicBrainzLabelInfo: Codable {
    let catalogNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case catalogNumber = "catalog-number"
    }
}

struct MusicBrainzArtistCredit: Codable {
    let name: String
    let joinphrase: String
}

struct MusicBrainzRelease: Codable {
    let id: String
    let date: String
    let title: String
    let disambiguation: String
    let media: [MusicBrainzMedia]
    let labelInfo: [MusicBrainzLabelInfo]
    let artistCredit: [MusicBrainzArtistCredit]
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case title
        case disambiguation
        case media
        case labelInfo = "label-info"
        case artistCredit = "artist-credit"
    }
}

struct MusicBrainzDiscIDLookupResponse: Codable {
    let releases: [MusicBrainzRelease]
}
