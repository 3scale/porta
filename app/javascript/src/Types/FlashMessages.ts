export interface FlashMessage {
  type: 'error' | 'notice' | 'success';
  message: string;
}
