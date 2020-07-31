import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';

class PhotoService {

  PhotoService(){  //init state
    _changeState = Action(_changeState);
  }

  File image=null;
  final picker = ImagePicker();

  Observable _stateOfFile = Observable(0); //este é o estado que vai mudar para sabermos que o File não é mais null

  int get getState => _stateOfFile.value; //retorna o valor de value em int

  Action _changeState; //ação que vai disparar o listener

  File get getImageFile => image;

  void changeState(){  //esta função vai ser chamada e vai incrementar o valor. Sempre que o valor mudar, será chamado o elemento na outra página que redesenha a tela.
    runInAction(
        () => {
        _stateOfFile.value++
        }
    );
  }

  Future getImage() async {  //upload da foto
    //final pickedFile = await picker.getImage(source: ImageSource.gallery);
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 20,
    );

    image = File(pickedFile.path);
    if(image != null){ //se o image é diferente de null, incrementa a variavel que está sendo observada
      changeState(); //se incrementar saberei que tem foto
    }

  }


}