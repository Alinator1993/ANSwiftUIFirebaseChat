//
//  ContentView.swift
//  ANSwiftUIFirebaseChat
//
//  Created by Allan Ntaate on 9/25/23.
//

import SwiftUI
import Firebase
import FirebaseStorage
class FireBaseManager : NSObject{
    
    let auth : Auth
    let storage: Storage
    static let shared = FireBaseManager()
    override init(){
        FirebaseApp.configure()
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        super.init()
    }
}
struct LoginView: View {
    
    
    
    @State var isLoginMode = true
    @State var email = ""
    @State var password = ""
    @State var shouldShowImagePicker = false
    
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(spacing: 16){
                    Picker(selection: $isLoginMode, label:Text("Picker Here")){
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode{
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            
                            VStack{
                                if let image = self.image{
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:128,height:128)
                                        .cornerRadius(64)
                                }
                                else{
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.black, lineWidth: 3))
                            
                        }
                        
                    }
                    
                    
                    TextField("Email", text: $email)
                        .padding(12)
                        .background(.white)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $password)
                        .padding(12)
                        .background(.white)
                    Button {
                        handleAction()
                    } label: {
                        HStack{
                            Spacer()
                            Text(isLoginMode ? "Log In":"Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical,10)
                            Spacer()
                        }.background(Color.blue)
                    }
                    Text(self.loginStatusMessage).foregroundColor(.red)
                }
                .padding()
                
            }
            .navigationTitle(isLoginMode ? "Log In" :  "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea()
            )
        }
        .navigationViewStyle(.stack)
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil){
            ImagePicker(image: $image)
        }
    }
    @State var image: UIImage?
    private func handleAction() {
        if isLoginMode {
            
            //print("Should log into Firebase with existing credentials")
            loginUser()
            
        } else {
            createNewAccount()
            //           print("Register a new account inside of Firebase Auth and then store image in Storage somehow....")
        }
    }
    
    @State var loginStatusMessage = ""
    
    private func loginUser(){
        FireBaseManager.shared.auth.signIn(withEmail: email, password: password){result, err in
            if let err = err {
                print("Failed to logi n user:", err)
                self.loginStatusMessage = "Failed to log in user: \(err)"
                return
            }
            print("Successfully logged in as User: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully logged in as User : \(result?.user.uid ?? "")"
        }
    }
    
    private func createNewAccount(){
        //        FirebaseManager.shared.auth.createUser(withEmail: email, password: password){result, err in
        FireBaseManager.shared.auth.createUser(withEmail: email, password: password){result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            print("Successfully created User: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully created User: \(result?.user.uid ?? "")"
            self.persistImageToStorage()
        }
    }
    private func persistImageToStorage(){
        guard let uid = FireBaseManager.shared.auth.currentUser?.uid
        else{return}
        let ref =  FireBaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {return }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err{
                self.loginStatusMessage = "Failed to Push Image to Storage \(err)"
                return
            }
            ref.downloadURL{url,err in
                if let err = err{
                    self.loginStatusMessage = "Failed to Retrieve Download URL \(err)"
                    return
                }
                self.loginStatusMessage = "Successfully Stored Image with URL: \(url?.absoluteString ?? "")"
            }
        }
    }
    
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            LoginView()
            //test
        }
    }
}
