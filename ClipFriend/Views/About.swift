//
//  About.swift
//  ClipFriend
//
//  Created by Ryan Dobron on 8/4/25.
//

import SwiftUI

struct About: View {
    var body: some View {
        NavigationStack
        {
            VStack{
                    Text("Version 1")
                    .padding()
                    .font(.headline)
                    Text("Made by Ryan Dobron")
                    Text("To contact me, email me at rakhmieldev@gmail.com")
                    Text("Support me on Ko-fi: https://ko-fi.com/rakhmiel")
                    .padding(.bottom)
            }
            .padding()
        }
        .navigationTitle(Text("About"))
    }
}

#Preview {
    About()
}
