
import React, { Component, PropTypes } from 'react';

import {
  NativeModules,
  TextInput,
  findNodeHandle,
  AppRegistry,
} from 'react-native';

const { CustomKeyboard } = NativeModules;

const {
  clear,
  install, uninstall,
  insertText, backSpace, doDelete,
  moveLeft, moveRight,
  replaceText,
  submit,
switchSystemKeyboard,
} = CustomKeyboard;

export {
  clear,
  install, uninstall,
  insertText, backSpace, doDelete,
  moveLeft, moveRight,
  replaceText,
  submit,
  switchSystemKeyboard,
};

const keyboardTypeRegistry = {};
const keyboardAccessoryRegistry = {};

export function registerKeyboard(type, factory) {
  keyboardTypeRegistry[type] = factory;
}

export function registerAccessory(type, factory) {
  keyboardAccessoryRegistry[type] = factory;
}

class CustomKeyboardContainer extends Component {
  render() {
    const {tag, type} = this.props;
    const factory = keyboardTypeRegistry[type];
    if (!factory) {
      console.warn(`Custom keyboard ${type} not registered.`);
      return null;
    }
    const Comp = factory();
    return <Comp {...this.props} tag={tag}/>;
  }
}

class CustomAccessoryContainer extends Component {
  render() {
    const {tag, type} = this.props;
    const factory = keyboardAccessoryRegistry[type];
    if (!factory) {
      console.warn(`Custom accessory ${type} not registered.`);
      return null;
    }
    const Comp = factory();
    return <Comp {...this.props} tag={tag}/>;
  }
}

AppRegistry.registerComponent("CustomKeyboard", ()=>CustomKeyboardContainer);
AppRegistry.registerComponent("CustomAccessory", ()=>CustomAccessoryContainer);

export class CustomTextInput extends Component {
  static propTypes = {
    ...TextInput.propTypes,
    customKeyboard: PropTypes.string,
    customAccessory: PropTypes.string
  };
  componentDidMount() {
    install(findNodeHandle(this.input), this.props.customKeyboard, undefined, 'input');
    install(findNodeHandle(this.input), this.props.customAccessory, undefined, 'accessory');
  }
  componentWillReceiveProps(newProps) {
    if (newProps.customKeyboard !== this.props.customKeyboard) {
      install(findNodeHandle(this.input), newProps.customKeyboard, undefined, 'input');
    }
    if (newProps.customAccessory !== this.props.customAccessory) {
      install(findNodeHandle(this.input), newProps.customAccessory, undefined, 'accessory');
    }
  }
  onRef = ref => {
    this.input = ref;
  };
  render() {
    const { customKeyboard, customAccessory, ...others } = this.props;
    return <TextInput {...others} ref={this.onRef}/>;
  }
}